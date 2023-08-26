import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myschedule/blocs/profile/profile_bloc.dart';
import 'package:myschedule/blocs/profile/profile_event.dart';
import 'package:myschedule/blocs/profile/profile_state.dart';
import 'package:myschedule/utils/profile/load_avatar.dart';
import 'package:myschedule/utils/profile/on_tap_avatar.dart';
import 'package:myschedule/views/screens/profile/edit_profile.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic> userData = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadUserData());
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<ProfileBloc>(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          );
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileDataState) {
            userData = state.userData;
          }
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text('Thông tin người dùng'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: userData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                getAvatar(userData, context);
                              },
                              child: CircleAvatar(
                                radius: 60,
                                child: Hero(
                                  tag: 'imageHero',
                                  child: FutureBuilder<Widget>(
                                    future: getImage(userData),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return FittedBox(
                                          fit: BoxFit.cover,
                                          child: snapshot.data!,
                                        );
                                      } else {
                                        return const Icon(Icons.person);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  userData['bio'] ?? '',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          enabled: false,
                          initialValue: userData['fullName'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Họ và tên',
                            border: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          enabled: false,
                          initialValue: userData['dob'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Ngày sinh',
                            border: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          enabled: false,
                          initialValue: userData['gender'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Giới tính',
                            border: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          enabled: false,
                          initialValue: userData['username'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Tên tài khoản',
                            border: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.person_pin),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          enabled: false,
                          initialValue: userData['phone'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại',
                            border: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.phone),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          enabled: false,
                          initialValue: userData['email'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.mail),
                          ),
                        ),
                        const SizedBox(height: 50.0),
                      ],
                    ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                profileBloc.add(EditProfileButtonPressed(context: context));
              },
              label: const Text('Chỉnh sửa thông tin'),
              icon: const Icon(Icons.edit),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }
}
