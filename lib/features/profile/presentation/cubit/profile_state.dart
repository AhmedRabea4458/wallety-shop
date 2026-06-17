import 'package:smart_expense/features/profile/domain/entities/profile_stats.dart';

abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final ProfileStats stats;

  ProfileLoaded({
    required this.stats,
  });
}
class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
