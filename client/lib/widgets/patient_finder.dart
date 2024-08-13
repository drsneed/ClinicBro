import 'package:fluent_ui/fluent_ui.dart';
import '../managers/patient_tab_manager.dart';
import '../models/patient_item.dart';
import '../repositories/user_repository.dart';
import '../repositories/patient_repository.dart';
import 'patient_display.dart';

class PatientFinder extends StatefulWidget {
  final VoidCallback? onDragStart;
  final void Function(PatientItem) onOpenChart;
  const PatientFinder({Key? key, this.onDragStart, required this.onOpenChart})
      : super(key: key);

  @override
  _PatientFinderState createState() => _PatientFinderState();
}

class _PatientFinderState extends State<PatientFinder> {
  int _currentIndex = 0;
  List<PatientItem> _recentPatients = [];
  List<PatientItem> _searchResults = [];
  List<PatientItem> _apptTodayPatients = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isApptTodayLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRecentPatients();
    _fetchApptTodayPatients();
  }

  Future<void> _fetchRecentPatients() async {
    final userRepository = UserRepository();
    final recentPatients = await userRepository.getRecentPatients();
    setState(() {
      _recentPatients = recentPatients;
      _isLoading = false;
    });
  }

  Future<void> _fetchApptTodayPatients() async {
    setState(() {
      _isApptTodayLoading = true;
    });

    final patientRepository = PatientRepository();
    final apptTodayPatients =
        await patientRepository.getPatientsWithAppointmentToday();

    setState(() {
      _apptTodayPatients = apptTodayPatients;
      _isApptTodayLoading = false;
    });
  }

  Future<void> _searchPatients(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final patientRepository = PatientRepository();
    final results = await patientRepository.searchPatients(searchTerm: query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleBarColor = FluentTheme.of(context).micaBackgroundColor;
    final titleBarHeight = 0.0;

    return ScaffoldPage(
      content: Column(
        children: [
          Container(
            //color: titleBarColor,
            height: titleBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Text(
                //     'Patient Finder',
                //     style: TextStyle(
                //       fontWeight: FontWeight.w500,
                //       fontSize: 16,
                //       color: FluentTheme.of(context).typography.body?.color ??
                //           Colors.black,
                //     ),
                //   ),
                // ),
                // Add any other header elements you need here
              ],
            ),
          ),
          Expanded(
            child: TabView(
              currentIndex: _currentIndex,
              onChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              tabs: [
                Tab(
                  text: const Text('Recent'),
                  body: _buildRecentContent(),
                  closeIcon: null,
                ),
                Tab(
                  text: const Text('Appt Today'),
                  body: _buildApptTodayContent(),
                  closeIcon: null,
                ),
                Tab(
                  text: const Text('Search'),
                  body: _buildSearchContent(),
                  closeIcon: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentContent() {
    if (_isLoading) {
      return Center(child: ProgressRing());
    }
    if (_recentPatients.isEmpty) {
      return Center(child: Text('No recent patients found.'));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _recentPatients.length,
        itemBuilder: (context, index) {
          return PatientDisplay(
            patient: _recentPatients[index],
            onDragStart: widget.onDragStart,
            onOpenChart: widget.onOpenChart,
          );
        },
      ),
    );
  }

  Widget _buildApptTodayContent() {
    if (_isApptTodayLoading) {
      return Center(child: ProgressRing());
    }
    if (_apptTodayPatients.isEmpty) {
      return Center(child: Text('No patients with appointments today.'));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _apptTodayPatients.length,
        itemBuilder: (context, index) {
          return PatientDisplay(
            patient: _apptTodayPatients[index],
            onDragStart: widget.onDragStart,
            onOpenChart: widget.onOpenChart,
          );
        },
      ),
    );
  }

  Widget _buildSearchContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search for Patients:',
            style: FluentTheme.of(context).typography.bodyLarge,
          ),
          SizedBox(height: 10),
          TextBox(
            controller: _searchController,
            placeholder: 'Enter patient name',
            onChanged: (value) {
              _searchPatients(value);
            },
          ),
          SizedBox(height: 10),
          Expanded(
            child: _isSearching
                ? Center(child: ProgressRing())
                : _searchResults.isEmpty
                    ? Center(child: Text('No results found'))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return PatientDisplay(
                            patient: _searchResults[index],
                            onDragStart: widget.onDragStart,
                            onOpenChart: widget.onOpenChart,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
