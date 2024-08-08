package utils

import (
	"fmt"
	"syscall"
	"unsafe"
)

// Constants for version info
const (
	VS_FF_PRIVATEBUILD   = 0x00000008
	VS_FF_SPECIALBUILD   = 0x00000010
	VS_FF_DEBUG          = 0x00000001
	VS_FF_RELEASABLE     = 0x00000002
	VS_FFI_FILEFLAGSMASK = 0x0000003F
)

// Windows API functions
var (
	modVersion                  = syscall.NewLazyDLL("version.dll")
	procGetFileVersionInfoSizeW = modVersion.NewProc("GetFileVersionInfoSizeW")
	procGetFileVersionInfoW     = modVersion.NewProc("GetFileVersionInfoW")
	procVerQueryValueW          = modVersion.NewProc("VerQueryValueW")
)

func GetFileVersionInfo(filename string) ([]byte, error) {
	// Convert filename to UTF-16
	utf16Filename, err := syscall.UTF16FromString(filename)
	if err != nil {
		return nil, err
	}
	size, _, _ := procGetFileVersionInfoSizeW.Call(uintptr(unsafe.Pointer(&utf16Filename[0])), 0)
	if size == 0 {
		return nil, fmt.Errorf("failed to get version info size")
	}

	versionData := make([]byte, size)
	ret, _, _ := procGetFileVersionInfoW.Call(uintptr(unsafe.Pointer(&utf16Filename[0])), 0, size, uintptr(unsafe.Pointer(&versionData[0])))
	if ret == 0 {
		return nil, fmt.Errorf("failed to get version info")
	}

	return versionData, nil
}

func GetVersionValue(data []byte, subBlock string) (string, error) {
	var lpBuf uintptr
	var bufLen uint32

	// Convert subBlock to UTF-16
	utf16SubBlock, err := syscall.UTF16FromString(subBlock)
	if err != nil {
		return "", err
	}
	ret, _, _ := procVerQueryValueW.Call(uintptr(unsafe.Pointer(&data[0])), uintptr(unsafe.Pointer(&utf16SubBlock[0])), uintptr(unsafe.Pointer(&lpBuf)), uintptr(unsafe.Pointer(&bufLen)))
	if ret == 0 {
		return "", fmt.Errorf("failed to query version value")
	}

	buf := (*uint16)(unsafe.Pointer(lpBuf))
	return syscall.UTF16ToString((*[1 << 30]uint16)(unsafe.Pointer(buf))[:bufLen/2]), nil
}
