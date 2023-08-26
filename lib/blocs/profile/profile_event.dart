import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class EditProfileButtonPressed extends ProfileEvent {
  final BuildContext context;

  const EditProfileButtonPressed({
    required this.context,
  });

  @override
  List<Object?> get props => [
        context,
      ];
}

class LoadUserData extends ProfileEvent {}
