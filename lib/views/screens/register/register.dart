import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myschedule/blocs/register/register_bloc.dart';
import 'package:myschedule/blocs/register/register_event.dart';
import 'package:myschedule/blocs/register/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  @override
  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  String _gender = 'Khác';
  final ValueNotifier<bool> _isPasswordVisibleNotifier =
      ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final registerBloc = BlocProvider.of<RegisterBloc>(context);
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Đăng ký thành công'),
                backgroundColor: Colors.green),
          );
        } else if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Đăng ký'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.person),
                      labelText: 'Tài khoản'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Không được để trống';
                    } else if (value.length < 6) {
                      return 'Độ dài ít nhất 6 ký tự';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<bool>(
                  valueListenable: _isPasswordVisibleNotifier,
                  builder: (context, isPasswordVisible, child) {
                    return TextFormField(
                      controller: _passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _isPasswordVisibleNotifier.value =
                                !isPasswordVisible;
                          },
                          child: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        labelText: 'Mật khẩu',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mật khẩu không được để trống';
                        } else if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        } else if (!RegExp(
                                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*])')
                            .hasMatch(value)) {
                          return 'Mật khẩu phải có chữ thường, chữ hoa, số và kí tự đặc biệt';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.person_outline_outlined),
                      labelText: 'Họ tên',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Không được để trống';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction),
                const SizedBox(height: 10),
                TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null ||
                          !RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Số điện thoại không hợp lệ';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction),
                const SizedBox(height: 10),
                TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.mail),
                    ),
                    validator: (value) {
                      if (value == null ||
                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction),
                const SizedBox(height: 10),
                TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        _dobController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Ngày, tháng, năm sinh',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ngày sinh không được bỏ trống';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: 'Giới tính',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.person_pin_rounded),
                  ),
                  value: _gender,
                  items: ['Nam', 'Nữ', 'Khác']
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _gender = value.toString();
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Đăng ký'),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      registerBloc.add(RegisterButtonPressed(
                        username: _usernameController.text,
                        password: _passwordController.text,
                        fullName: _fullNameController.text,
                        phone: _phoneController.text,
                        email: _emailController.text,
                        dob: _dobController.text,
                        gender: _gender,
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Đăng ký không thành công!\nVui lòng kiểm tra các thông tin đăng ký'),
                          backgroundColor: Colors.red));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
