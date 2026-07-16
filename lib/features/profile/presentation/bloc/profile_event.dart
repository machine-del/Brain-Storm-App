part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateUserNameEvent extends ProfileEvent {
  final String name;

  const UpdateUserNameEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

class RefreshProfileEvent extends ProfileEvent {}