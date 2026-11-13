import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../../ui/theme/space.dart';
import '../../../../../ui/theme/theme.dart';

Future<void> showAvailabilityDialog(
  BuildContext context, {
  required String roomNumber,
  required int availableSeats,
  required ValueChanged<int> onSave,
}) async {
  final value = await showDialog<int>(
    context: context,
    builder: (_) => AvailabilityDialog(roomNumber: roomNumber, availableSeats: availableSeats),
  );
  if (value != null) onSave(value);
}

class AvailabilityDialog extends StatefulWidget {
  const AvailabilityDialog({super.key, required this.roomNumber, required this.availableSeats});

  final String roomNumber;
  final int availableSeats;

  @override
  State<AvailabilityDialog> createState() => _AvailabilityDialogState();
}

class _AvailabilityDialogState extends State<AvailabilityDialog> {
  late String _valueText = '${widget.availableSeats}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final value = int.tryParse(_valueText);

    final validationError = switch (value) {
      null => 'Please enter a valid number',
      < 0 => 'Availability cannot be negative',
      _ => null,
    };
    final hasChanged = value != null && value != widget.availableSeats;

    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text('Room ${widget.roomNumber} Availability'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.lg,
        children: [
          Text('Currently available: ${widget.availableSeats}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: (value ?? 0) > 0
                    ? () => setState(() => _valueText = '${(value ?? 0) - 1}')
                    : null,
                tooltip: 'Decrease availability',
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 100,
                child: AuthInputTextField(
                  value: _valueText,
                  onValueChange: (v) => setState(() => _valueText = v),
                  icon: null,
                  placeholder: '',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _valueText = '${(value ?? 0) + 1}'),
                tooltip: 'Increase availability',
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (validationError != null)
            Text(validationError, style: context.typos.bodySmall?.copyWith(color: colors.error)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: validationError == null && hasChanged
              ? () => Navigator.of(context).pop(value)
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
