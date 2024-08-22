import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'Utility/colors_font.dart';
import 'Utility/user_model.dart';
import 'homepage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String pathimg = dotenv.get("API_PATH_IMG", fallback: "");

class historypage extends StatefulWidget {
  historypage({Key? key, required this.user, required this.userdata})
      : super(key: key);

  final List<dynamic> userdata;
  final User user;

  @override
  State<historypage> createState() => _historypageState();
}

class _historypageState extends State<historypage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<dynamic> _filteredData = [];

  void _selectDate(context) async {
    showCustomDateRangePicker(
      context,
      dismissible: true,
      minimumDate: DateTime.now().subtract(const Duration(days: 365)),
      maximumDate: DateTime.now().add(const Duration(days: 365)),
      endDate: _endDate,
      startDate: _startDate,
      backgroundColor: Colors.white,
      primaryColor: primaryColor,
      onApplyClick: (start, end) {
        setState(() {
          _endDate = end;
          _startDate = start;
          _filteredData = filterDataByDateRange(start, end);
        });
      },
      onCancelClick: () {
        setState(() {
          _endDate = null;
          _startDate = null;
          _filteredData.clear();
        });
      },
    );
  }

  List<dynamic> filterDataByDateRange(DateTime startDate, DateTime endDate) {
    return widget.userdata.where((userData) {
      String? dateString = userData['time_att'];
      if (dateString != null) {
        DateTime userDateTime = DateTime.parse(dateString);
        return userDateTime.isAfter(
          startDate.subtract(
            const Duration(days: 1),
          )) &&
          userDateTime.isBefore(
            endDate.add(
              const Duration(days: 1),
            ),
          );
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredData = _filteredData.isNotEmpty
        ? _filteredData
        : _startDate != null
          ? filterDataByDateRange(_startDate!, _endDate!)
          : widget.userdata;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: primaryColor,
          title: Text(
            'แสดงประวัติ',
            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
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
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () {
                _selectDate(context);
              },
            ),
          ],
        ),
        body: filteredData.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ไม่พบประวัติ',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                'ไม่มีประวัติของท่านในวันนี้...โปรดติดต่อเจ้าหน้าที่',
                style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                ),
              ),
            ],
          ),
        )
        : ListView.builder(
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            var userData = filteredData[index];
            String usertime = userData['time_att'];
            String? userpicture = userData['img'];
            return SafeArea(
              child: Card(
                margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                color: primaryColor,
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.date_range,
                                    color: Colors.white,
                                    size: MediaQuery.of(context).size.width * 0.05,
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width * 0.015),
                                  Text(
                                    usertime.split(' ')[0],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: MediaQuery.of(context).size.width * 0.05,
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width * 0.015),
                                  Text(
                                    usertime.split(' ')[1],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              _showFullScreenImage(userpicture);
                            },
                            child: Stack(
                              children: [
                                userpicture != null
                                    ? Image.network(
                                        '$pathimg/$userpicture',
                                        width: MediaQuery.of(context).size.width * 0.3,
                                        height: MediaQuery.of(context).size.height * 0.15,
                                        fit: BoxFit.cover,
                                      )
                                    : SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.3,
                                        height: MediaQuery.of(context).size.height * 0.15,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                        ),
                                      ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.zoom_in,
                                      size: MediaQuery.of(context).size.height * 0.03,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
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
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFullScreenImage(String? userpicture) {
    if (userpicture != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Image.network('$pathimg/$userpicture'),
          );
        },
      );
    }
  }
}