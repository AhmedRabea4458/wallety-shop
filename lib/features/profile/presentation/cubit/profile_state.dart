import 'package:smart_expense/features/profile/domain/entities/profile_stats.dart';

abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final ProfileStats stats;
  final double budget;
  final double monthlySpent;

  ProfileLoaded({
    required this.stats,
    required this.budget,
    required this.monthlySpent,
  });
}
class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
