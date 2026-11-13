import '../../../core/presentation/widgets/step_progress_indicator.dart';

enum PropertyStep implements ProgressStep {
  basicInfo('Basic Info'),
  location('Location'),
  propertyDetails('Property Details'),
  facilities('Facilities'),
  rooms('Rooms');

  const PropertyStep(this.label);

  @override
  final String label;

  static const progressSteps = [propertyDetails, basicInfo, location, facilities, rooms];

  static const updateProgressSteps = [propertyDetails, basicInfo, location, facilities];
}
