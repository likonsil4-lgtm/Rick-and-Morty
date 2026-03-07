import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/characters/characters_cubit.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedStatus;
  String? selectedGender;

  final List<String> statuses = ['alive', 'dead', 'unknown'];
  final List<String> genders = ['female', 'male', 'genderless', 'unknown'];

  bool get _hasActiveFilters => selectedStatus != null || selectedGender != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Characters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedStatus = null;
                      selectedGender = null;
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: statuses.map((status) => ChoiceChip(
              label: Text(status.toUpperCase()),
              selected: selectedStatus == status,
              onSelected: (selected) {
                setState(() => selectedStatus = selected ? status : null);
              },
            )).toList(),
          ),
          const SizedBox(height: 20),

          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: genders.map((gender) => ChoiceChip(
              label: Text(gender.toUpperCase()),
              selected: selectedGender == gender,
              onSelected: (selected) {
                setState(() => selectedGender = selected ? gender : null);
              },
            )).toList(),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final cubit = context.read<CharactersCubit>();

                if (_hasActiveFilters) {
                  cubit.updateFilters(
                    status: selectedStatus,
                    gender: selectedGender,
                  );
                  Navigator.pop(context);
                } else {
                  cubit.resetAllFilters();
                  Navigator.pop(context);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_hasActiveFilters ? 'Filters applied' : 'Showing all characters'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _hasActiveFilters ? 'Apply Filters' : 'Show All Characters',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}