import 'package:messseat/data/dto/auth/auth_dtos.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/data/repository/auth_repository.dart';
import 'package:messseat/domain/enums/gender.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void registerAuthFallbacks() {
  registerFallbackValue(const EmailRequest(''));
  registerFallbackValue(
    const RegisterRequest(
      fullName: '',
      email: '',
      phone: '',
      password: '',
      gender: Gender.MALE,
      role: Role.TENANT,
    ),
  );
}
