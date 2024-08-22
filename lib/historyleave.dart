import 'package:flutter/material.dart';
import 'Utility/colors_font.dart';
import 'Utility/user_model.dart';
import 'leaveformpage.dart';
import 'homepage.dart';

class historyleave extends StatefulWidget {
  const historyleave({Key? key, required this.user, required this.userdata})
      : super(key: key);

  final Map<String, dynamic> userdata;
  final User user;

  @override
  State<historyleave> createState() => _historyleaveState();
}

class _historyleaveState extends State<historyleave> {
  int selectedYear = DateTime.now().year;
  int currentPage = 1;
  int itemsPerPage = 5;
  List<dynamic> historyData = [];
  List<dynamic> filteredHistoryData = [];

  @override
  void initState() {
    super.initState();
    historyData = widget.userdata['History'] ?? [];
    filteredHistoryData = getDisplayedHistoryData();
  }

  List<dynamic> getDisplayedHistoryData() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (startIndex >= historyData.length) {
      currentPage--;
      return [];
    }
    return historyData.sublist(
      startIndex,
      endIndex.clamp(0, historyData.length),
    );
  }

  void nextPage() {
    setState(() {
      currentPage++;
    });
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  void _resetData() {
    setState(() {
      selectedYear = DateTime.now().year;
      filteredHistoryData = historyData
          .where((entry) =>
              DateTime.parse(entry['start_date']).year == selectedYear)
          .toList();
    });
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }

  Map<String, String> leaveTypeMap = {
    'PL': 'ลากิจ',
    'SL': 'ลาป่วย',
    'VL': 'ลาพักร้อน',
  };
  

  @override
  Widget build(BuildContext context) {
    var userleftday = widget.userdata['info'];
    String vl = userleftday['VL'];
    String sl = userleftday['SL'];
    String pl = userleftday['PL'];
    List<dynamic> historyData = widget.userdata['History'] ?? [];
    List<dynamic> filteredHistoryData = historyData
        .where(
            (entry) => DateTime.parse(entry['start_date']).year == selectedYear)
        .toList();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'การลา',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 8,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home_Page(
                  user: widget.user,
                ),
              ),
            );
          },
        ),
        actions: [
        if (vl != '0' || sl != '0' || pl != '0')
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              List<String> leavesWithZeroValue = [];
              if (vl == '0') {
                leavesWithZeroValue.add('ลากิจ');
              }
              if (sl == '0') {
                leavesWithZeroValue.add('ลาป่วย');
              }
            if (pl == '0') {
              leavesWithZeroValue.add('ลาพักร้อน');
            }
            _showAlertPopup(context, leavesWithZeroValue);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                pl,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'ลากิจ',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                sl,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'ลาป่วย',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                vl,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'ลาพักร้อน',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(
                      DateTime.now().year - 2012 + 1,
                      (index) {
                        return DropdownMenuItem<int>(
                          value: DateTime.now().year - index,
                          child: Text(
                            (DateTime.now().year - index).toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                    onChanged: (int? year) {
                      setState(() {
                        selectedYear = year!;
                        filteredHistoryData = historyData
                            .where((entry) =>
                                DateTime.parse(entry['start_date']).year ==
                                selectedYear)
                            .toList();
                        currentPage = 1;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: currentPage > 1 ? previousPage : null,
                    color: Colors.blue,
                    iconSize: 35,
                  ),
                  Text(
                    'Page $currentPage of ${((filteredHistoryData.length - 1) ~/ itemsPerPage) + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed:
                        currentPage * itemsPerPage < filteredHistoryData.length
                            ? nextPage
                            : null,
                    color: Colors.blue,
                    iconSize: 35,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _resetData,
                    color: Colors.grey,
                    iconSize: 25,
                  ),
                ],
              ),
              _buildHistoryDataTable(filteredHistoryData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryDataTable(List<dynamic> historyData) {
    List<DataRow> dataRows = [];
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (historyData.isEmpty) {
      return const Text('ยังไม่มีประวัติการลา');
    }
    for (int i = startIndex; i < historyData.length && i < endIndex; i++) {
      var historyEntry = historyData[i];
      String leaveType = leaveTypeMap[historyEntry['leave_type']] ?? historyEntry['leave_type'];
      String statusText = '';
      Color statusColor = Colors.black;
      int statusHr = historyEntry['status_hr'];
      if (statusHr == 1) {
        statusText = 'Waiting';
        statusColor = Colors.blue;
      } else if (statusHr == 2) {
        statusText = 'Approve';
        statusColor = Colors.green;
      } else if (statusHr == 0) {
        statusText = 'Cancel';
        statusColor = Colors.red;
      }
      DataRow dataRow = DataRow(
        cells: [
          DataCell(
            Text(formatDateTime(historyEntry['created_at'])
            )
          ),
          DataCell(
            Text(leaveType)
          ),
          DataCell(
            Text(
              statusText,
              style: TextStyle(color: statusColor),
            ),
          ),
        ],
      );
      dataRows.add(dataRow);
    }
    return DataTable(
      columns: const [
        DataColumn(label: Text('วันที่')),
        DataColumn(label: Text('ประเภท')),
        DataColumn(label: Text('สถานะ')),
      ],
      rows: dataRows,
    );
  }

  void _showAlertPopup(BuildContext context, List<String> leavesWithZeroValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String alertContent = '';
        if (leavesWithZeroValue.isNotEmpty) {
          alertContent =
              'ดูเหมือนวัน "${leavesWithZeroValue.join(', ')}" ของท่านจะหมด';
        } else {
          alertContent = 'ต้องการกรอกแบบฟอร์มการขอลา?';
        }
        return AlertDialog(
          title: const Text('แจ้งเตือน'),
          content: Text(alertContent),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => leaveformpage(
                      user: widget.user,
                      userdata: widget.userdata,
                    ),
                  ),
                );
              },
              child: const Text('ทำต่อไป'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }
}
