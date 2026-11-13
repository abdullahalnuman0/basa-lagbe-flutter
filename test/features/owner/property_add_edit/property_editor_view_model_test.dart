import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/dto/property/property_dtos.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/data/repository/file_repository.dart';
import 'package:messseat/data/repository/property_repository.dart';
import 'package:messseat/domain/enums/property_gender.dart';
import 'package:messseat/domain/enums/property_type.dart';
import 'package:messseat/domain/model/room.dart';
import 'package:messseat/features/auth/signup/location_data.dart';
import 'package:messseat/features/owner/property_add_edit/property_editor_view_model.dart';
import 'package:messseat/features/owner/property_add_edit/property_step.dart';
import 'package:mocktail/mocktail.dart';

class _MockFileRepository extends Mock implements FileRepository {}

class _MockPropertyRepository extends Mock implements PropertyRepository {}

PropertyResponse _property({int id = 7, String contactNumber = '+8801712345678'}) =>
    PropertyResponse(
      id: id,
      title: 'Green View Hostel',
      description: 'Quiet place near campus',
      approved: true,
      division: 'Khulna',
      district: 'Jessore',
      area: 'Chowgacha',
      address: '24/4 A, Saha road',
      contactNumber: contactNumber,
      gender: PropertyGender.MALE,
      type: PropertyType.HOSTEL,
      institutionNearby: 'JUST',
      facilities: const ['Wi-Fi', 'Parking'],
      rooms: const [],
      createdAt: DateTime(2025),
    );

Room _room({List<String> images = const ['a.jpg']}) => Room(
  roomNumber: 'R-101',
  rent: 3000,
  deposit: 1000,
  availableSeats: 2,
  roomWidth: 10,
  roomHeight: 12,
  type: RoomType.DOUBLE,
  images: images,
);

void main() {
  late _MockFileRepository fileRepo;
  late _MockPropertyRepository propertyRepo;
  late PropertyEditorViewModel vm;

  setUpAll(() {
    registerFallbackValue(
      const PropertyRequest(
        address: '',
        area: '',
        contactNumber: '',
        description: '',
        district: '',
        division: '',
        facilities: [],
        gender: PropertyGender.ANY,
        rooms: [],
        title: '',
        type: PropertyType.MESS,
      ),
    );
    registerFallbackValue(
      const PropertyUpdateRequest(
        address: '',
        area: '',
        contactNumber: '',
        description: '',
        district: '',
        division: '',
        facilities: [],
        gender: PropertyGender.ANY,
        title: '',
        type: PropertyType.MESS,
      ),
    );
  });

  setUp(() {
    fileRepo = _MockFileRepository();
    propertyRepo = _MockPropertyRepository();
    vm = PropertyEditorViewModel(fileRepo, propertyRepo);
  });

  tearDown(() => vm.dispose());

  Future<void> next({void Function(int)? onSuccess, void Function(String)? onError}) =>
      vm.onGoNext(onSuccess: onSuccess ?? (_) {}, onError: onError ?? (_) {});

  /// Fills in every step and walks the wizard up to the last one.
  Future<void> walkToLastStep() async {
    vm
      ..onTypeSelect(PropertyType.MESS)
      ..onGenderSelect(PropertyGender.ANY);
    await next();
    vm
      ..onTitleChange('Green View Hostel')
      ..onPhoneChange('01712345678');
    await next();
    vm
      ..onAreaChange('  Palbari ')
      ..onAddressChange('Road 3 ');
    await next();
    vm.onAddFacilities('Wi-Fi');
    await next();
  }

  group('initial state', () {
    test('starts on property details with the create flow', () {
      expect(vm.state.currentStep, PropertyStep.propertyDetails);
      expect(vm.state.progressSteps, PropertyStep.progressSteps);
      expect(vm.state.lastStep, PropertyStep.rooms);
      expect(vm.state.division, LocationData.divisions.first);
      expect(
        vm.state.district,
        LocationData.districtByDivision[LocationData.divisions.first]!.first,
      );
    });

    test('initiateEditorState switches to the update flow and copies the property', () {
      vm.initiateEditorState(_property());

      final s = vm.state;
      expect(s.progressSteps, PropertyStep.updateProgressSteps);
      expect(s.lastStep, PropertyStep.facilities);
      expect(s.property?.id, 7);
      expect(s.type, PropertyType.HOSTEL);
      expect(s.gender, PropertyGender.MALE);
      expect(s.contactNumber, '01712345678');
      expect(s.district, 'Jessore');
      expect(s.facilities, {'Wi-Fi', 'Parking'});
    });

    test('initiateEditorState ignores null', () {
      vm.initiateEditorState(null);
      expect(vm.state.property, isNull);
      expect(vm.state.progressSteps, PropertyStep.progressSteps);
    });
  });

  group('field changes', () {
    test('phone keeps digits only and at most 11 of them', () {
      vm.onPhoneChange('+88 017-1234-56789');
      expect(vm.state.contactNumber, '88017123456');
    });

    test('description is capped at 500 characters', () {
      vm.onDescChange('x' * 600);
      expect(vm.state.description.length, 500);
    });

    test('changing division resets district to its first entry', () {
      final division = LocationData.divisions[1];
      vm.onDivisionSelect(division);
      expect(vm.state.district, LocationData.districtByDivision[division]!.first);
    });

    test('facilities can be added, removed and cleared', () {
      vm
        ..onAddFacilities('Wi-Fi')
        ..onAddFacilities('Gas')
        ..onRemoveFacilities('Wi-Fi');
      expect(vm.state.facilities, {'Gas'});

      vm.onAllFacilitiesRemove();
      expect(vm.state.facilities, isEmpty);
    });
  });

  group('step validation', () {
    test('property details needs a type, then a gender', () async {
      await next();
      expect(vm.state.propertyDetailsError, 'Please select a property type.');
      expect(vm.state.currentStep, PropertyStep.propertyDetails);
      expect(vm.state.isLoading, isFalse);

      vm.onTypeSelect(PropertyType.FLAT);
      expect(vm.state.propertyDetailsError, isNull);
      await next();
      expect(vm.state.propertyDetailsError, 'Please select who can move into this property.');

      vm.onGenderSelect(PropertyGender.FEMALE);
      await next();
      expect(vm.state.currentStep, PropertyStep.basicInfo);
      expect(vm.state.isNavigatingForward, isTrue);
    });

    test('basic info rejects a blank title and a bad phone', () async {
      vm
        ..onTypeSelect(PropertyType.FLAT)
        ..onGenderSelect(PropertyGender.FEMALE);
      await next();

      vm
        ..onTitleChange('   ')
        ..onPhoneChange('0121234567');
      await next();

      expect(vm.state.titleError, 'Please enter a valid listing title. ');
      expect(vm.state.contactNumberError, 'Enter a valid phone number.');
      expect(vm.state.currentStep, PropertyStep.basicInfo);

      vm.onTitleChange('Flat');
      expect(vm.state.titleError, isNull);
    });

    test('location trims the area and address', () async {
      vm
        ..onAreaChange('   ')
        ..onAddressChange('');
      expect(vm.validateLocation(), isFalse);
      expect(vm.state.areaError, 'Enter your property area');
      expect(vm.state.addressError, 'Enter your property address.');

      vm
        ..onAreaChange(' Palbari ')
        ..onAddressChange(' Road 3');
      expect(vm.validateLocation(), isTrue);
      expect(vm.state.area, 'Palbari');
      expect(vm.state.address, 'Road 3');
    });

    test('facilities and rooms must not be empty', () {
      expect(vm.validateFacilities(), isFalse);
      expect(vm.state.facilitiesError, 'Please select at least one facility.');

      expect(vm.validateRooms(), isFalse);
      expect(vm.state.roomsError, 'Please add at least one room.');

      vm.onAddRoom(_room());
      expect(vm.state.roomsError, isNull);
      expect(vm.validateRooms(), isTrue);
    });

    test('onGoBack moves one step back and stops at the first step', () async {
      await walkToLastStep();
      expect(vm.state.currentStep, PropertyStep.rooms);

      vm.onGoBack();
      expect(vm.state.currentStep, PropertyStep.facilities);
      expect(vm.state.isNavigatingForward, isFalse);

      for (var i = 0; i < 10; i++) {
        vm.onGoBack();
      }
      expect(vm.state.currentStep, PropertyStep.propertyDetails);
    });
  });

  group('rooms', () {
    test('removing a room deletes its uploaded images', () {
      when(() => fileRepo.deleteAll(any())).thenAnswer((_) async => const ApiSuccess(null));
      final room = _room(images: ['a.jpg', 'b.jpg']);

      vm.onAddRoom(room);
      vm.onRemoveRoom(room);

      expect(vm.state.rooms, isEmpty);
      verify(() => fileRepo.deleteAll(['a.jpg', 'b.jpg'])).called(1);
    });

    test('onUpdate replaces the room at the given index', () {
      final updated = _room().copyWith(roomNumber: 'R-202');
      vm
        ..onAddRoom(_room())
        ..onAddRoom(_room())
        ..onUpdate(1, updated);

      expect(vm.state.rooms[1].roomNumber, 'R-202');
      expect(vm.state.rooms[0].roomNumber, 'R-101');
    });
  });

  group('submit', () {
    test('create builds a PropertyRequest with rooms and reports the new id', () async {
      when(() => propertyRepo.create(any())).thenAnswer((_) async => ApiSuccess(_property(id: 42)));

      await walkToLastStep();
      vm.onAddRoom(_room());

      int? createdId;
      await next(onSuccess: (id) => createdId = id);

      expect(createdId, 42);
      expect(vm.state.isLoading, isFalse);

      final request =
          verify(() => propertyRepo.create(captureAny())).captured.single as PropertyRequest;
      expect(request.type, PropertyType.MESS);
      expect(request.gender, PropertyGender.ANY);
      expect(request.title, 'Green View Hostel');
      expect(request.contactNumber, '01712345678');
      expect(request.area, 'Palbari');
      expect(request.address, 'Road 3');
      expect(request.facilities, ['Wi-Fi']);
      expect(request.rooms.single.roomNumber, 'R-101');
      expect(request.rooms.single.type, RoomType.DOUBLE);
      expect(request.rooms.single.images, ['a.jpg']);
      verifyNever(() => propertyRepo.update(any(), any()));
    });

    test('rooms step blocks submit until a room is added', () async {
      await walkToLastStep();
      await next();

      expect(vm.state.roomsError, 'Please add at least one room.');
      verifyNever(() => propertyRepo.create(any()));
    });

    test('update sends a PropertyUpdateRequest after the facilities step', () async {
      when(() => propertyRepo.update(any(), any()))
          .thenAnswer((_) async => ApiSuccess(_property()));

      vm.initiateEditorState(_property());
      for (var i = 0; i < 3; i++) {
        await next();
      }
      expect(vm.state.currentStep, PropertyStep.facilities);

      vm.onAddFacilities('Gas');
      int? updatedId;
      await next(onSuccess: (id) => updatedId = id);

      expect(updatedId, 7);
      final captured = verify(() => propertyRepo.update(7, captureAny())).captured;
      final request = captured.single as PropertyUpdateRequest;
      expect(request.title, 'Green View Hostel');
      expect(request.contactNumber, '01712345678');
      expect(request.facilities, containsAll(['Wi-Fi', 'Parking', 'Gas']));
      verifyNever(() => propertyRepo.create(any()));
    });

    test('api errors are passed to onError', () async {
      when(() => propertyRepo.create(any()))
          .thenAnswer((_) async => const ApiError<PropertyResponse>('Title already taken'));

      await walkToLastStep();
      vm.onAddRoom(_room());

      String? error;
      var succeeded = false;
      await next(onSuccess: (_) => succeeded = true, onError: (e) => error = e);

      expect(error, 'Title already taken');
      expect(succeeded, isFalse);
      expect(vm.state.isLoading, isFalse);
    });

    test('unexpected failures show the generic message', () async {
      when(() => propertyRepo.create(any())).thenThrow(Exception('boom'));

      await walkToLastStep();
      vm.onAddRoom(_room());

      String? error;
      await next(onError: (e) => error = e);

      expect(error, 'Something wat wrong! please tray again later.');
      expect(vm.state.isLoading, isFalse);
    });
  });
}
