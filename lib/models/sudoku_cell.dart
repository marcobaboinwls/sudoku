class SudokuCell {
  int? value;
  bool isInitial;
  List<int> annotations;

  SudokuCell({
    this.value,
    this.isInitial = false,
    List<int>? annotations,
  }) : annotations = annotations ?? [];

  SudokuCell copyWith({
    int? value,
    bool? isInitial,
    List<int>? annotations,
  }) {
    return SudokuCell(
      value: value ?? this.value,
      isInitial: isInitial ?? this.isInitial,
      annotations: annotations ?? List.from(this.annotations),
    );
  }
}
