class ExtraDataState {
  final int bodyBaseCalories;
  final int maintenanceCalories;

  ExtraDataState({this.bodyBaseCalories = 0, this.maintenanceCalories = 0});

  ExtraDataState copyWith({
    int? bodyBaseCalories,
    double? dailyWeight,
    int? maintenanceCalories,
  }) {
    return ExtraDataState(
      bodyBaseCalories: bodyBaseCalories ?? this.bodyBaseCalories,
      maintenanceCalories: maintenanceCalories ?? this.maintenanceCalories,
    );
  }
}
