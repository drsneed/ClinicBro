import 'package:fluent_ui/fluent_ui.dart';
import '../models/patient_item.dart';
import '../repositories/user_repository.dart';
import 'patient_display.dart';

class PatientFinder extends StatefulWidget {
  final VoidCallback? onDragStart; // Add this line
  const PatientFinder({Key? key, this.onDragStart}) : super(key: key);
  @override
  _PatientFinderState createState() => _PatientFinderState();
}

class _PatientFinderState extends State<PatientFinder> {
  int _currentIndex = 0; // To track the currently selected tab
  List<PatientItem> _recentPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentPatients();
  }

  Future<void> _fetchRecentPatients() async {
    final userRepository = UserRepository();
    final recentPatients = await userRepository.getRecentPatients();
    setState(() {
      _recentPatients = recentPatients;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Column(
        children: [
          // TabView
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

  // Method to build content for the "Recent" tab
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
          );
        },
      ),
    );
  }

  // Method to build content for the "Appt Today" tab
  Widget _buildApptTodayContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointments Today:',
            style: FluentTheme.of(context).typography.bodyLarge,
          ),
          SizedBox(height: 10),
          // Example content for "Appt Today"
          Text('Patient X - 10:00 AM'),
          Text('Patient Y - 11:30 AM'),
        ],
      ),
    );
  }

  // Method to build content for the "Search" tab
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
          // Example content for "Search"
          TextBox(
            placeholder: 'Enter patient name',
          ),
        ],
      ),
    );
  }
}
