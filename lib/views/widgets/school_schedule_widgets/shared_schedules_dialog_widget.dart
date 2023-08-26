import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myschedule/utils/school_schedule/day_schedule_utils.dart';

class SharedSchedulesDialog extends StatefulWidget {
  final List<Map<String, dynamic>> sharedSchedules;
  final String currentUsername;
  final List<TextEditingController> subjectControllers;
  final CollectionReference usersCollection;
  final CollectionReference sharedSchedulesCollection;
  final CollectionReference schedulesCollection;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String day;

  SharedSchedulesDialog({
    required this.sharedSchedules,
    required this.currentUsername,
    required this.subjectControllers,
    required this.usersCollection,
    required this.sharedSchedulesCollection,
    required this.schedulesCollection,
    required this.scaffoldKey,
    required this.day,
  });

  @override
  _SharedSchedulesDialogState createState() => _SharedSchedulesDialogState();
}

class _SharedSchedulesDialogState extends State<SharedSchedulesDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Danh sách thời khóa biểu được chia sẻ'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.sharedSchedules.isEmpty
              ? [
                  const Center(
                    child: Text(
                      'Danh sách trống',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  )
                ]
              : widget.sharedSchedules.map((schedule) {
                  final sharedUserId = schedule['sharedUserId'] as String?;
                  final fullName = schedule['fullName'] as String?;
                  final scheduleId = schedule['scheduleId'] as String?;
                  final avatarURL = schedule['avatarURL'] as String?;
                  if (sharedUserId == widget.currentUsername) {
                    return ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Xóa tài liệu'),
                                    content: const Text(
                                        'Bạn có chắc muốn xóa tài liệu này?'),
                                    actions: [
                                      TextButton(
                                        child: const Text('Hủy'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Xác nhận'),
                                        onPressed: () async {
                                          final userQuerySnapshot = await widget
                                              .usersCollection
                                              .where('username',
                                                  isEqualTo: sharedUserId)
                                              .get();

                                          if (userQuerySnapshot
                                              .docs.isNotEmpty) {
                                            final userId =
                                                userQuerySnapshot.docs[0].id;
                                            await widget
                                                .sharedSchedulesCollection
                                                .where('scheduleId',
                                                    isEqualTo: scheduleId)
                                                .where('sharedUserId',
                                                    isEqualTo: sharedUserId)
                                                .limit(1)
                                                .get()
                                                .then((querySnapshot) {
                                              if (querySnapshot
                                                  .docs.isNotEmpty) {
                                                querySnapshot
                                                    .docs.first.reference
                                                    .delete();
                                                ScaffoldMessenger.of(widget
                                                            .scaffoldKey
                                                            .currentContext ??
                                                        context)
                                                    .hideCurrentSnackBar();

                                                Navigator.of(context).pop();

                                                ScaffoldMessenger.of(widget
                                                            .scaffoldKey
                                                            .currentContext ??
                                                        context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Đã xóa tài liệu được chia sẻ từ $fullName"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );

                                                Navigator.pop(context);
                                                loadDataForDay(widget.day,
                                                    widget.subjectControllers);
                                              } else {
                                                ScaffoldMessenger.of(widget
                                                            .scaffoldKey
                                                            .currentContext ??
                                                        context)
                                                    .hideCurrentSnackBar();

                                                ScaffoldMessenger.of(widget
                                                            .scaffoldKey
                                                            .currentContext ??
                                                        context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Không thể xóa tài liệu'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }).catchError((error) {
                                              ScaffoldMessenger.of(widget
                                                          .scaffoldKey
                                                          .currentContext ??
                                                      context)
                                                  .hideCurrentSnackBar();

                                              ScaffoldMessenger.of(widget
                                                          .scaffoldKey
                                                          .currentContext ??
                                                      context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Có lỗi xảy ra. Không thể xóa tài liệu.'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            });
                                          } else {
                                            ScaffoldMessenger.of(widget
                                                        .scaffoldKey
                                                        .currentContext ??
                                                    context)
                                                .hideCurrentSnackBar();

                                            ScaffoldMessenger.of(widget
                                                        .scaffoldKey
                                                        .currentContext ??
                                                    context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Không thể xóa tài liệu'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 20),
                          avatarURL != null
                              ? CachedNetworkImage(
                                  imageUrl: avatarURL,
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                    backgroundImage: imageProvider,
                                    radius: 16,
                                  ),
                                  placeholder: (context, url) =>
                                      const CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: 16,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: 16,
                                  ),
                                )
                              : const CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 16,
                                ),
                        ],
                      ),
                      title: Text(fullName ?? ''),
                      onTap: () async {
                        final scheduleDoc = await widget.schedulesCollection
                            .doc(scheduleId)
                            .get();
                        final scheduleData = scheduleDoc.data();
                        if (scheduleData is Map &&
                            scheduleData[widget.day] != null) {
                          setState(() {
                            for (var i = 0; i < 12; i++) {
                              final subjectData =
                                  scheduleData[widget.day] as Map?;
                              widget.subjectControllers[i].text =
                                  subjectData?['subject${i + 1}'] ?? '';
                            }
                          });
                          ScaffoldMessenger.of(
                                  widget.scaffoldKey.currentContext ?? context)
                              .hideCurrentSnackBar();

                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(
                                  widget.scaffoldKey.currentContext ?? context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Đã lấy dữ liệu thời khóa biểu thứ hai từ $fullName"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(
                                  widget.scaffoldKey.currentContext ?? context)
                              .hideCurrentSnackBar();

                          ScaffoldMessenger.of(
                                  widget.scaffoldKey.currentContext ?? context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                  "$fullName chưa cập nhật thời khóa biểu thứ hai"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                    );
                  } else {
                    return Container();
                  }
                }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Đóng'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
