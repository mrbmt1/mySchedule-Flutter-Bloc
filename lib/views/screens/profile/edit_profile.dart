import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:myschedule/validators/validator_form.dart';
import 'package:myschedule/views/screens/profile/profile.dart';
import 'package:myschedule/views/widgets/profile/edit_profile/show_snack_bar_widget.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  String _gender = 'Khác';
  final List<String> _genderList = ['Nam', 'Nữ', 'Khác'];
  late String avatarURL;
  late String userId = FirebaseAuth.instance.currentUser!.uid;
  final _validatorForm = ValidatorForm();

  void _updateProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
    final data = snapshot.data();
    final fullname = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final bio = _bioController.text.trim();
    final dob = _dobController.text.trim();
    final gender = _gender;

    if (fullname.isEmpty || phone.isEmpty || email.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin'),
            backgroundColor: Colors.red),
      );
    } else if (fullname == data!['fullName'] &&
        phone == data['phone'] &&
        email == data['email'] &&
        dob == data['dob'] &&
        bio == data['bio'] &&
        gender == data['gender']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Không có thông tin nào được thay đổi'),
            backgroundColor: Colors.green),
      );
    } else if (_formKey.currentState!.validate()) {
      final existingUserByEmail = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('uid', isNotEqualTo: currentUser?.uid)
          .get();
      final existingUserByPhone = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .where('uid', isNotEqualTo: currentUser?.uid)
          .get();
      if (existingUserByEmail.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Email đã được sử dụng bởi người khác'),
              backgroundColor: Colors.red),
        );
      } else if (existingUserByPhone.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Số điện thoại đã được sử dụng bởi người khác'),
              backgroundColor: Colors.red),
        );
      } else {
        Map<String, dynamic> updatedFields = {};
        if (fullname != data['fullName']) {
          updatedFields['fullName'] = fullname;
        }
        if (phone != data['phone'] &&
            _validatorForm.validatePhone(phone) == true) {
          updatedFields['phone'] = phone;
        }
        if (email != data['email'] &&
            _validatorForm.validateEmail(email) == true) {
          updatedFields['email'] = email;
        }
        if (dob != data['dob']) {
          updatedFields['dob'] = dob;
        }
        if (gender != data['gender']) {
          updatedFields['gender'] = gender;
        }
        if (bio != data['bio']) {
          updatedFields['bio'] = bio;
        }

        if (updatedFields.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser?.uid)
              .update(updatedFields)
              .then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Cập nhật thông tin thành công'),
                  backgroundColor: Colors.green),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserProfileScreen()),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Có lỗi xảy ra khi cập nhật thông tin'),
                  backgroundColor: Colors.red),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Không có thông tin nào được thay đổi'),
                backgroundColor: Colors.green),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: userId)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        _usernameController.text = data['username'] ?? '';
        _fullNameController.text = data['fullName'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _emailController.text = data['email'] ?? '';
        _bioController.text = data['bio'] ?? '';
        avatarURL = data['avatarURL'] ?? '';
        final dob = data['dob'] ?? '';
        DateTime? dobDateTime;
        if (dob is String) {
          try {
            dobDateTime = DateFormat('dd/MM/yyyy').parse(dob);
            _dobController.text = DateFormat('dd/MM/yyyy').format(dobDateTime);
          } catch (e) {
            debugPrint('Error parsing date: $e');
            _dobController.text = '';
          }
        } else if (dob is Timestamp) {
          dobDateTime = dob.toDate();
          _dobController.text = DateFormat('dd/MM/yyyy').format(dobDateTime);
        }
        final gender = data['gender'] as String?;
        if (gender != null) {
          _gender = gender;
        }
        if (data.containsKey('avatarURL')) {
          avatarURL = data['avatarURL'];
        }
        setState(() {});
      }
    });
  }

  Future<Widget> _getAvatar() async {
    if (avatarURL.isNotEmpty) {
      try {
        final ref =
            firebase_storage.FirebaseStorage.instance.refFromURL(avatarURL);
        final url = await ref.getDownloadURL();
        return ClipOval(
          child: Image.network(
            url,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        debugPrint('Error loading image: $e');
      }
    }
    return const CircleAvatar(
      radius: 60,
      child: Icon(Icons.person),
    );
  }

  void _uploadAvatar() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = '${FirebaseAuth.instance.currentUser!.uid}.jpg';
      final destination = 'avatars/$userId/$fileName';
      try {
        // Cắt ảnh thành hình vuông
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: file.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cắt ảnh',
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
          ],
        );

        if (croppedFile != null) {
          final tempDir = await getTemporaryDirectory();
          final tempPath = '${tempDir.path}/cropped_image.jpg';

          final croppedBytes = await croppedFile.readAsBytes();
          await File(tempPath).writeAsBytes(croppedBytes);

          final tempFile = File(tempPath);

          // Tiếp tục xử lý tệp tạm thời

          final croppedRef = firebase_storage.FirebaseStorage.instance
              .ref('cropped_$destination');
          final croppedUploadTask = croppedRef.putFile(tempFile);
          final croppedSnapshot = await croppedUploadTask.whenComplete(() {});
          final croppedUrl = await croppedSnapshot.ref.getDownloadURL();

          setState(() {
            avatarURL = croppedUrl;
          });

          // Lưu URL vào collection users của Firebase Firestore
          final currentUser = FirebaseAuth.instance.currentUser;
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .update({'avatarURL': croppedUrl});
        } else {
          // print('No image selected or cropped');
        }
      } catch (e) {
        // print('Error uploading avatar: $e');
      }
    }
  }

  Future<void> _downloadAvatar() async {
    // Kiểm tra xem URL có tồn tại không
    if (avatarURL.isNotEmpty) {
      // Tạo thư mục lưu trữ
      final directory = await getApplicationDocumentsDirectory();
      // Lấy đường dẫn tệp tin để lưu trữ tệp hình ảnh
      final file = File('${directory.path}/avatar.png');
      try {
        // Tải tệp hình ảnh từ URL và lưu trữ vào thiết bị
        await firebase_storage.FirebaseStorage.instance
            .refFromURL(avatarURL)
            .writeToFile(file);
        // Lưu trữ tệp hình ảnh vào thư viện hình ảnh của thiết bị
        final result = await ImageGallerySaver.saveFile(file.path);
        // print('File saved to gallery: $result');

        showSnackBar(context, 'Ảnh đã được tải thành công.');

        // Tạo thông báo
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 0,
            channelKey: 'basic_channel',
            title: 'Thông báo',
            body: 'Ấn vào đây để xem ảnh',
            bigPicture: 'file://${file.path}', // Đường dẫn đến ảnh đã tải
            notificationLayout: NotificationLayout.BigPicture,
          ),
        );
      } catch (e) {
        // print('Error downloading avatar: $e');
      }
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Xem ảnh đại diện'),
                onTap: () async {
                  try {
                    final ref = firebase_storage.FirebaseStorage.instance
                        .refFromURL(avatarURL);
                    final url = await ref.getDownloadURL();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return Scaffold(
                          backgroundColor: Colors.black,
                          body: Stack(
                            children: [
                              Positioned.fill(
                                child: Hero(
                                  tag: 'imageHero',
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 30,
                                right: 10,
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  } catch (e) {
                    // print('Error loading image: $e');
                  }
                  // Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Đổi ảnh đại diện'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadAvatar();
                  // Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Tải ảnh đại diện'),
                onTap: () {
                  _downloadAvatar();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật thông tin'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    CircleAvatar(
                      radius: 60,
                      child: Hero(
                        tag: 'imageHero',
                        child: GestureDetector(
                          onTap: () {
                            _showAvatarOptions();
                          },
                          child: FutureBuilder<Widget>(
                            future: _getAvatar(),
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
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên đăng nhập',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person_outline),
                      ),
                      validator: _validatorForm.validateFullName,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.phone),
                      ),
                      validator: _validatorForm.validatePhone,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.email),
                      ),
                      validator: _validatorForm.validateEmail,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: 'Ngày sinh',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? dob = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (dob == null) return;
                        _dobController.text =
                            DateFormat('dd/MM/yyyy').format(dob);
                      },
                      validator: _validatorForm.validateDob,
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      items: _genderList
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        _gender = value!;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Giới tính',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.work_outlined),
                      ),
                    ),
                    const SizedBox(height: 50.0),
                  ])))),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateProfile,
        child: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
