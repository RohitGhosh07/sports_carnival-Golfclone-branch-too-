import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:rpgl/bases/api/refereeandmarshal.dart';
import 'package:rpgl/bases/themes.dart';
import 'package:url_launcher/url_launcher.dart';

class RefereeAndMarshalScreen extends StatefulWidget {
  @override
  _RefereeAndMarshalScreenState createState() =>
      _RefereeAndMarshalScreenState();
}

class _RefereeAndMarshalScreenState extends State<RefereeAndMarshalScreen> {
  late Future<RefereeAndMarshalAPI> _refereeAndMarshalFuture;

  @override
  void initState() {
    super.initState();
    _refereeAndMarshalFuture = RefereeAndMarshalAPI.refreelist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Referee and Marshal',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<RefereeAndMarshalAPI>(
          future: _refereeAndMarshalFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching data'));
            } else if (!snapshot.hasData ||
                snapshot.data!.marshalDetails == null) {
              return Center(child: Text('No data available'));
            } else {
              List<Referees> referees =
                  snapshot.data!.marshalDetails!.referees ?? [];
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Determine the number of columns based on screen width
                  int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

                  return GridView.builder(
                    itemCount: referees.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      Referees referee = referees[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: referee.image != null &&
                                        referee.image!.isNotEmpty
                                    ? NetworkImage(referee.image!)
                                    : AssetImage('assets/placeholder.png')
                                        as ImageProvider,
                                backgroundColor: Colors.grey[300],
                                onBackgroundImageError: (_, __) {
                                  // Error handling for image loading
                                },
                                child: referee.image == null ||
                                        referee.image!.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              SizedBox(height: 8),
                              Flexible(
                                child: Text(
                                  referee.name ?? 'No name',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Flexible(
                                child: Text(
                                  referee.role ?? 'No role',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.call),
                                    color: AppThemes.getBackground(),
                                    onPressed: () {
                                      // Add call functionality here
                                      _makePhoneCall('${referee.phone}');
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _sendWhatsApp('${referee.phone}',
                                          'Hello $referee.name');
                                    },
                                    icon: SvgPicture.asset(
                                      'assets/images/whatsapp.svg',
                                      color: Colors.green,
                                      semanticsLabel: 'WhatsApp Icon',
                                      height: 24, // Set your desired height
                                      width: 24, // Set your desired width
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

void _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}

// void _sendEmail(String email) async {
//   final Uri emailUri =
//       Uri(scheme: 'mailto', path: email, queryParameters: {'subject': 'Hello'});
//   await launchUrl(emailUri);
// }

void _sendWhatsApp(String phoneNumber, String message) async {
  // Ensure phone number is in international format without any "+" or spaces
  phoneNumber = phoneNumber.replaceAll('+', '').replaceAll(' ', '');

  // WhatsApp URL with encoded message
  String url =
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch WhatsApp';
  }
}
