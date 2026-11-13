import '../../../core/presentation/widgets/step_progress_indicator.dart';

enum SignupStep implements ProgressStep {
  roleSelection(''),
  basicInfo('Basic Info'),
  aboutYou('About you'),
  location('Location'),
  security('Security');

  const SignupStep(this.label);

  @override
  final String label;

  static const progressSteps = [basicInfo, aboutYou, location, security];
}
