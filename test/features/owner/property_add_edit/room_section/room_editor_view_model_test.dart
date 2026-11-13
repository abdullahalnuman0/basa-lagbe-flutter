import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/data/repository/file_repository.dart';
import 'package:messseat/domain/model/room.dart';
import 'package:messseat/features/owner/property_add_edit/room_section/room_editor_view_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockFileRepository extends Mock implements FileRepository {}

void main() {
  late _MockFileRepository fileRepo;
  late RoomEditorViewModel vm;

  setUpAll(() => registerFallbackValue(XFile('fallback.jpg')));

  setUp(() {
    fileRepo = _MockFileRepository();
    vm = RoomEditorViewModel(fileRepo);
    when(() => fileRepo.delete(any())).thenAnswer((_) async => const ApiSuccess(null));
    when(() => fileRepo.deleteAll(any())).thenAnswer((_) async => const ApiSuccess(null));
  });

  tearDown(() => vm.dispose());

  void fillValidForm() {
    vm
      ..onRoomNumberChange(' R-7 ')
      ..onTypeSelected(RoomType.SINGLE)
      ..onSeatChange('2')
      ..onRentChange('3500')
      ..onDepositChange('1000')
      ..onWidthChange('10')
      ..onHeightChange('12');
  }

  group('field validation', () {
    test('room number is required', () {
      vm.onRoomNumberChange('  ');
      expect(vm.state.roomNumberError, 'Room number is required.');

      vm.onRoomNumberChange('A1');
      expect(vm.state.roomNumberError, isNull);
    });

    test('numbers must be present, numeric and positive', () {
      vm.onRentChange('');
      expect(vm.state.rentError, 'Rent is required');

      vm.onRentChange('12a');
      expect(vm.state.rentError, 'Give the correct number.');

      vm.onRentChange('0');
      expect(vm.state.rentError, 'Rent must be greater than 0');

      vm.onSeatChange('-1');
      expect(vm.state.availableSeatsError, 'Available seats must be greater than 0');

      vm.onRentChange('500');
      expect(vm.state.rentError, isNull);
    });

    test('deposit is optional', () {
      vm.onDepositChange('');
      expect(vm.state.deposit, '');
    });
  });

  group('initialRoom / closeInitial', () {
    test('initialRoom fills the form and blanks out zero values', () {
      vm.initialRoom(
        Room(roomNumber: 'B-2', rent: 4000, roomWidth: 9, type: RoomType.FAMILY, images: ['k1']),
      );

      expect(vm.state.roomNumber, 'B-2');
      expect(vm.state.rent, '4000');
      expect(vm.state.deposit, '');
      expect(vm.state.availableSeats, '');
      expect(vm.state.roomWidth, '9');
      expect(vm.state.type, RoomType.FAMILY);
      expect(vm.state.images.single.fileKey, 'k1');
      expect(vm.state.images.single.file, isNull);
    });

    test('closeInitial resets the form and deletes uploaded images when asked', () {
      vm.initialRoom(Room(roomNumber: 'B-2', images: ['k1', 'k2']));

      vm.closeInitial(true);

      expect(vm.state.roomNumber, isEmpty);
      expect(vm.state.images, isEmpty);
      verify(() => fileRepo.deleteAll(['k1', 'k2'])).called(1);
    });

    test('closeInitial keeps the files after a save', () {
      vm.initialRoom(Room(roomNumber: 'B-2', images: ['k1']));

      vm.closeInitial(false);

      expect(vm.state.images, isEmpty);
      verifyNever(() => fileRepo.deleteAll(any()));
    });
  });

  group('image upload', () {
    test('uploads every picked file and stores the returned keys', () async {
      final a = XFile('a.jpg');
      final b = XFile('b.jpg');
      when(() => fileRepo.upload(a, 'properties')).thenAnswer((_) async => const ApiSuccess('ka'));
      when(() => fileRepo.upload(b, 'properties')).thenAnswer((_) async => const ApiSuccess('kb'));

      await vm.onUploadImages([a, b]);

      expect(vm.state.images.map((it) => it.fileKey), ['ka', 'kb']);
      expect(vm.state.images.every((it) => !it.isUploading), isTrue);
      expect(vm.state.isLoading, isFalse);
    });

    test('marks a failed upload with the error message', () async {
      final a = XFile('a.jpg');
      when(() => fileRepo.upload(a, any()))
          .thenAnswer((_) async => const ApiError<String>('Images must be under 2MB.'));

      await vm.onUploadImages([a]);

      final stash = vm.state.images.single;
      expect(stash.fileKey, isNull);
      expect(stash.error, 'Images must be under 2MB.');
      expect(stash.isUploading, isFalse);
    });

    test('never goes beyond the max photo count', () async {
      when(() => fileRepo.upload(any(), any())).thenAnswer((_) async => const ApiSuccess('key'));

      await vm.onUploadImages(List.generate(4, (i) => XFile('$i.jpg')));
      await vm.onUploadImages(List.generate(4, (i) => XFile('more$i.jpg')));

      expect(vm.state.images, hasLength(5));
      verify(() => fileRepo.upload(any(), any())).called(5);

      await vm.onUploadImages([XFile('extra.jpg')]);
      verifyNoMoreInteractions(fileRepo);
    });

    test('ignores new picks while an upload is running', () async {
      final pending = Completer<ApiResult<String>>();
      when(() => fileRepo.upload(any(), any())).thenAnswer((_) => pending.future);

      final first = vm.onUploadImages([XFile('a.jpg')]);
      expect(vm.state.isLoading, isTrue);
      expect(vm.state.images.single.isUploading, isTrue);

      await vm.onUploadImages([XFile('b.jpg')]);
      expect(vm.state.images, hasLength(1));

      pending.complete(const ApiSuccess('ka'));
      await first;
      expect(vm.state.images.single.fileKey, 'ka');
    });

    test('retry uploads the same file again', () async {
      final a = XFile('a.jpg');
      when(() => fileRepo.upload(a, any())).thenAnswer((_) async => const ApiError('Network'));
      await vm.onUploadImages([a]);

      when(() => fileRepo.upload(a, any())).thenAnswer((_) async => const ApiSuccess('ka'));
      await vm.onRetry(0, vm.state.images.first);

      expect(vm.state.images.single.fileKey, 'ka');
      expect(vm.state.images.single.error, isNull);
    });

    test('removing an uploaded image deletes it on the server', () async {
      final a = XFile('a.jpg');
      when(() => fileRepo.upload(a, any())).thenAnswer((_) async => const ApiSuccess('ka'));
      await vm.onUploadImages([a]);

      vm.onRemoveImage(vm.state.images.single);

      expect(vm.state.images, isEmpty);
      verify(() => fileRepo.delete('ka')).called(1);
    });

    test('a photo removed mid-upload does not receive another photo\'s result', () async {
      final a = XFile('a.jpg');
      final b = XFile('b.jpg');
      final pendingA = Completer<ApiResult<String>>();
      when(() => fileRepo.upload(a, any())).thenAnswer((_) => pendingA.future);
      when(() => fileRepo.upload(b, any())).thenAnswer((_) async => const ApiSuccess('kb'));

      final upload = vm.onUploadImages([a, b]);
      vm.onRemoveImage(vm.state.images.first);
      pendingA.complete(const ApiSuccess('ka'));
      await upload;

      expect(vm.state.images.single.file, b);
      expect(vm.state.images.single.fileKey, 'kb');
    });
  });

  group('onAddRoom', () {
    test('flags every missing field and does not save', () {
      Room? saved;
      vm.onAddRoom((room) => saved = room);

      expect(saved, isNull);
      expect(vm.state.roomNumberError, 'Room number is required.');
      expect(vm.state.rentError, 'Rent is required');
      expect(vm.state.availableSeatsError, 'Available seats is required');
      expect(vm.state.roomWidthError, 'Room width is required');
      expect(vm.state.roomHeightError, 'Room height is required');
      expect(vm.state.typeError, 'Please select room type');
      expect(vm.state.imageError, 'Please select at last one image.');
    });

    test('builds the room from a valid form', () async {
      final a = XFile('a.jpg');
      when(() => fileRepo.upload(a, any())).thenAnswer((_) async => const ApiSuccess('ka'));
      fillValidForm();
      await vm.onUploadImages([a]);

      Room? saved;
      vm.onAddRoom((room) => saved = room);

      expect(saved, isNotNull);
      expect(saved!.roomNumber, 'R-7');
      expect(saved!.type, RoomType.SINGLE);
      expect(saved!.availableSeats, 2);
      expect(saved!.rent, 3500);
      expect(saved!.deposit, 1000);
      expect(saved!.roomWidth, 10);
      expect(saved!.roomHeight, 12);
      expect(saved!.images, ['ka']);
    });
  });
}
