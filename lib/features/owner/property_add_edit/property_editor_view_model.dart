import 'package:flutter/foundation.dart';

import '../../../core/network/api_result.dart';
import '../../../data/dto/property/property_dtos.dart';
import '../../../data/dto/room/room_dtos.dart';
import '../../../data/repository/file_repository.dart';
import '../../../data/repository/property_repository.dart';
import '../../../domain/enums/property_gender.dart';
import '../../../domain/enums/property_type.dart';
import '../../../domain/model/room.dart';
import '../../auth/signup/location_data.dart';
import 'property_editor_ui_state.dart';
import 'property_step.dart';

class PropertyEditorViewModel extends ChangeNotifier {
  PropertyEditorViewModel(this._fileRepo, this._propertyRepo);

  final FileRepository _fileRepo;
  final PropertyRepository _propertyRepo;

  static final _phoneRegex = RegExp(r'^01[3-9]\d{8}$');

  PropertyEditorUiState _state = PropertyEditorUiState();
  PropertyEditorUiState get state => _state;

  bool _disposed = false;

  void _update(PropertyEditorUiState Function(PropertyEditorUiState s) transform) {
    _state = transform(_state);
    if (!_disposed) notifyListeners();
  }

  int get _currentIndex => _state.progressSteps.indexOf(_state.currentStep);

  //---------------------------------
  //    Initiate Editor State
  //---------------------------------
  void initiateEditorState(PropertyResponse? property) {
    if (property == null) return;
    final phone = property.contactNumber;

    _update(
      (_) => PropertyEditorUiState(
        progressSteps: PropertyStep.updateProgressSteps,
        property: property,
        type: property.type,
        gender: property.gender,
        title: property.title,
        description: property.description,
        contactNumber: phone.length > 11 ? phone.substring(phone.length - 11) : phone,
        division: property.division,
        district: property.district,
        area: property.area,
        address: property.address,
        institutionNearby: property.institutionNearby,
        facilities: property.facilities.toSet(),
      ),
    );
  }

  // --- basic info ---
  void onTitleChange(String value) => _update((s) => s.copyWith(title: value, titleError: null));

  void onDescChange(String value) =>
      _update((s) => s.copyWith(description: value.length > 500 ? value.substring(0, 500) : value));

  void onPhoneChange(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    _update(
      (s) => s.copyWith(
        contactNumber: digits.length > 11 ? digits.substring(0, 11) : digits,
        contactNumberError: null,
      ),
    );
  }

  bool _validateBasicInfo() {
    String? titleError;
    String? phoneError;

    if (_state.title.trim().isEmpty) titleError = 'Please enter a valid listing title. ';
    if (!_phoneRegex.hasMatch(_state.contactNumber)) phoneError = 'Enter a valid phone number.';

    _update((s) => s.copyWith(titleError: titleError, contactNumberError: phoneError));
    return titleError == null && phoneError == null;
  }

  // --- location ---
  void onDivisionSelect(String value) => _update(
    (s) => s.copyWith(
      division: value,
      district: LocationData.districtByDivision[value]!.first,
      divisionError: null,
    ),
  );

  void onDistrictSelect(String value) =>
      _update((s) => s.copyWith(district: value, districtError: null));

  void onAreaChange(String value) => _update((s) => s.copyWith(area: value, areaError: null));

  void onAddressChange(String value) =>
      _update((s) => s.copyWith(address: value, addressError: null));

  void onInstitutionChange(String value) => _update((s) => s.copyWith(institutionNearby: value));

  bool validateLocation() {
    final area = _state.area.trim();
    final address = _state.address.trim();

    final areaError = area.isEmpty ? 'Enter your property area' : null;
    final addressError = address.isEmpty ? 'Enter your property address.' : null;

    _update(
      (s) => s.copyWith(
        areaError: areaError,
        addressError: addressError,
        area: area,
        address: address,
      ),
    );
    return areaError == null && addressError == null;
  }

  // --- property details ---
  void onTypeSelect(PropertyType type) =>
      _update((s) => s.copyWith(type: type, propertyDetailsError: null));

  void onGenderSelect(PropertyGender gender) =>
      _update((s) => s.copyWith(gender: gender, propertyDetailsError: null));

  bool canContinuePropertyDetails() {
    if (_state.type == null) {
      _update((s) => s.copyWith(propertyDetailsError: 'Please select a property type.'));
      return false;
    }
    if (_state.gender == null) {
      _update(
        (s) => s.copyWith(propertyDetailsError: 'Please select who can move into this property.'),
      );
      return false;
    }
    return true;
  }

  // --- facilities ---
  void onAddFacilities(String value) =>
      _update((s) => s.copyWith(facilities: {...s.facilities, value}, facilitiesError: null));

  void onRemoveFacilities(String value) => _update(
    (s) => s.copyWith(facilities: {...s.facilities}..remove(value), facilitiesError: null),
  );

  void onAllFacilitiesRemove() =>
      _update((s) => s.copyWith(facilities: const {}, facilitiesError: null));

  bool validateFacilities() {
    if (_state.facilities.isEmpty) {
      _update((s) => s.copyWith(facilitiesError: 'Please select at least one facility.'));
      return false;
    }
    return true;
  }

  // --- rooms ---
  void onAddRoom(Room room) =>
      _update((s) => s.copyWith(rooms: [...s.rooms, room], roomsError: null));

  void onRemoveRoom(Room room) {
    _update((s) => s.copyWith(rooms: [...s.rooms]..remove(room), roomsError: null));
    _fileRepo.deleteAll(room.images);
  }

  void onUpdate(int index, Room room) =>
      _update((s) => s.copyWith(rooms: [...s.rooms]..[index] = room));

  bool validateRooms() {
    if (_state.rooms.isEmpty) {
      _update((s) => s.copyWith(roomsError: 'Please add at least one room.'));
      return false;
    }
    return true;
  }

  // --- navigation ---
  Future<void> onGoNext({
    required ValueChanged<int> onSuccess,
    required ValueChanged<String> onError,
  }) async {
    _update((s) => s.copyWith(isLoading: true));

    final valid = switch (_state.progressSteps[_currentIndex]) {
      PropertyStep.propertyDetails => canContinuePropertyDetails(),
      PropertyStep.basicInfo => _validateBasicInfo(),
      PropertyStep.location => validateLocation(),
      PropertyStep.facilities => validateFacilities(),
      PropertyStep.rooms => validateRooms(),
    };

    if (!valid) {
      _update((s) => s.copyWith(isLoading: false));
      return;
    }

    final curr = _state;
    final index = _currentIndex;

    if (index != curr.progressSteps.length - 1) {
      _update(
        (s) => s.copyWith(
          currentStep: s.progressSteps[index + 1],
          isNavigatingForward: true,
          isLoading: false,
        ),
      );
      return;
    }

    try {
      final property = curr.property;
      final result = property != null
          ? await _propertyRepo.update(property.id, _updateRequest(curr))
          : await _propertyRepo.create(_createRequest(curr));

      switch (result) {
        case ApiError(:final message):
          onError(message);
        case ApiSuccess(:final data):
          onSuccess(data.id);
      }
    } catch (_) {
      onError('Something wat wrong! please tray again later.');
    } finally {
      _update((s) => s.copyWith(isLoading: false));
    }
  }

  void onGoBack() {
    final index = _currentIndex;
    if (index == 0) return;

    _update((s) => s.copyWith(currentStep: s.progressSteps[index - 1], isNavigatingForward: false));
  }

  PropertyUpdateRequest _updateRequest(PropertyEditorUiState s) => PropertyUpdateRequest(
    type: s.type!,
    gender: s.gender!,
    title: s.title,
    contactNumber: s.contactNumber,
    description: s.description,
    district: s.district,
    division: s.division,
    area: s.area,
    address: s.address,
    institutionNearby: s.institutionNearby,
    facilities: s.facilities.toList(),
  );

  PropertyRequest _createRequest(PropertyEditorUiState s) => PropertyRequest(
    type: s.type!,
    gender: s.gender!,
    title: s.title,
    contactNumber: s.contactNumber,
    description: s.description,
    district: s.district,
    division: s.division,
    area: s.area,
    address: s.address,
    institutionNearby: s.institutionNearby,
    facilities: s.facilities.toList(),
    rooms: [
      for (final room in s.rooms)
        RoomRequest(
          availableSeats: room.availableSeats,
          deposit: room.deposit,
          images: room.images,
          rent: room.rent,
          roomHeight: room.roomHeight,
          roomNumber: room.roomNumber,
          roomWidth: room.roomWidth,
          type: room.type!,
        ),
    ],
  );

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
