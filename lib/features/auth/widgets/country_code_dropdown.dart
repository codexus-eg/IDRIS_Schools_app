import 'package:flutter/material.dart';

import '../../../core/models/country_code.dart';

class CountryCodeDropdown extends StatelessWidget {
  const CountryCodeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isArabic,
  });

  final CountryCode value;
  final ValueChanged<CountryCode> onChanged;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CountryCode>(
      value: value,
      decoration: InputDecoration(
        labelText: isArabic ? 'مفتاح الدولة' : 'Country code',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: CountryCodes.all.map((CountryCode item) {
        return DropdownMenuItem<CountryCode>(
          value: item,
          child: Text(
            item.label(isArabic),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (CountryCode? item) {
        if (item == null) return;
        onChanged(item);
      },
    );
  }
}
