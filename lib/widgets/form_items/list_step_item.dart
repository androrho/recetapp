import 'package:flutter/material.dart';

/// Holds a single text controller for one step in the recipe.
///
/// Each list item uses one [stepController] to read or edit the step’s text.
class ListStepItem {
  final TextEditingController stepController;

  ListStepItem({required this.stepController});
}