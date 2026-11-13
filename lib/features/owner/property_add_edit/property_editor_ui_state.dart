import '../../../data/dto/property/property_dtos.dart';
import '../../../domain/enums/property_gender.dart';
import '../../../domain/enums/property_type.dart';
import '../../../domain/model/room.dart';
import '../../auth/signup/location_data.dart';
import 'property_step.dart';

const _keep = Object();

class PropertyEditorUiState {
  PropertyEditorUiState({
    this.progressSteps = PropertyStep.progressSteps,
    PropertyStep? currentStep,
    PropertyStep? lastStep,
    this.isNavigatingForward = true,
    this.property,
    this.title = '',
    this.titleError,
    this.description = '',
    this.contactNumber = '',
    this.contactNumberError,
    String? division,
    this.divisionError,
    String? district,
    this.districtError,
    this.area = '',
    this.areaError,
    this.address = '',
    this.addressError,
    this.institutionNearby = '',
    this.type,
    this.gender,
    this.propertyDetailsError,
    this.facilities = const {},
    this.facilitiesError,
    this.rooms = const [],
    this.roomsError,
    this.isLoading = false,
  }) : currentStep = currentStep ?? progressSteps.first,
       lastStep = lastStep ?? progressSteps.last,
       division = division ?? LocationData.divisions.first,
       district =
           district ??
           LocationData.districtByDivision[division ?? LocationData.divisions.first]!.first;

  final List<PropertyStep> progressSteps;
  final PropertyStep currentStep;
  final PropertyStep lastStep;
  final bool isNavigatingForward;

  // --- updated property ---
  final PropertyResponse? property;

  // --- Step 1 - Basic Info ---
  final String title;
  final String? titleError;
  final String description;
  final String contactNumber;
  final String? contactNumberError;

  // --- Step 2 - Location ---
  final String division;
  final String? divisionError;
  final String district;
  final String? districtError;
  final String area;
  final String? areaError;
  final String address;
  final String? addressError;
  final String institutionNearby;

  // --- Step 3 - Property Details ---
  final PropertyType? type;
  final PropertyGender? gender;
  final String? propertyDetailsError;

  // --- Step 4 - Facilities ---
  final Set<String> facilities;
  final String? facilitiesError;

  // --- Step 5 - Rooms ---
  final List<Room> rooms;
  final String? roomsError;

  final bool isLoading;

  PropertyEditorUiState copyWith({
    PropertyStep? currentStep,
    bool? isNavigatingForward,
    String? title,
    Object? titleError = _keep,
    String? description,
    String? contactNumber,
    Object? contactNumberError = _keep,
    String? division,
    Object? divisionError = _keep,
    String? district,
    Object? districtError = _keep,
    String? area,
    Object? areaError = _keep,
    String? address,
    Object? addressError = _keep,
    String? institutionNearby,
    PropertyType? type,
    PropertyGender? gender,
    Object? propertyDetailsError = _keep,
    Set<String>? facilities,
    Object? facilitiesError = _keep,
    List<Room>? rooms,
    Object? roomsError = _keep,
    bool? isLoading,
  }) {
    T? pick<T>(Object? value, T? current) => identical(value, _keep) ? current : value as T?;

    return PropertyEditorUiState(
      progressSteps: progressSteps,
      currentStep: currentStep ?? this.currentStep,
      lastStep: lastStep,
      isNavigatingForward: isNavigatingForward ?? this.isNavigatingForward,
      property: property,
      title: title ?? this.title,
      titleError: pick(titleError, this.titleError),
      description: description ?? this.description,
      contactNumber: contactNumber ?? this.contactNumber,
      contactNumberError: pick(contactNumberError, this.contactNumberError),
      division: division ?? this.division,
      divisionError: pick(divisionError, this.divisionError),
      district: district ?? this.district,
      districtError: pick(districtError, this.districtError),
      area: area ?? this.area,
      areaError: pick(areaError, this.areaError),
      address: address ?? this.address,
      addressError: pick(addressError, this.addressError),
      institutionNearby: institutionNearby ?? this.institutionNearby,
      type: type ?? this.type,
      gender: gender ?? this.gender,
      propertyDetailsError: pick(propertyDetailsError, this.propertyDetailsError),
      facilities: facilities ?? this.facilities,
      facilitiesError: pick(facilitiesError, this.facilitiesError),
      rooms: rooms ?? this.rooms,
      roomsError: pick(roomsError, this.roomsError),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
