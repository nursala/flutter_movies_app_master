// lib/widgets/dropdown_filters.dart
import 'package:flutter/material.dart';
import '../models/genre.dart';
// Labels are passed in via constructor now

class DropdownFilters extends StatelessWidget {
  final String selectedType;
  final String selectedSort;
  final int? selectedGenreId;
  final List<Genre> genres;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<int?> onGenreChanged;
  // Added parameters for localized labels
  final Map<String, String> typeLabels; // e.g., {'movie': 'Film', 'tv': 'Serie'}
  final Map<String, String> sortLabels; // e.g., {'popular': 'Beliebt', ...}
  final String allGenresLabel;

  const DropdownFilters({
    super.key,
    required this.selectedType,
    required this.selectedSort,
    required this.selectedGenreId,
    required this.genres,
    required this.onTypeChanged,
    required this.onSortChanged,
    required this.onGenreChanged,
    // Require localized labels
    required this.typeLabels,
    required this.sortLabels,
    required this.allGenresLabel,
  });

  @override
  Widget build(BuildContext context) { // Context is available here
    // Determine sort options based on selected type (keys remain the same)
    final sortOptions = (selectedType == 'movie'
        ? ['popular', 'now_playing', 'top_rated', 'upcoming'] // Example keys
        : ['popular', 'now_playing', 'top_rated', 'upcoming'] // Example keys for TV
    ); // Use actual keys from constants.dart if needed

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          // Type Dropdown (Movie/TV)
          Expanded(
            child: _buildDropdown<String>( // Pass context here
              context, // <--- PASS CONTEXT
              value: selectedType,
              items: ['movie', 'tv'].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        type == 'movie' ? Icons.movie_filter_outlined : Icons.tv_outlined,
                        color: Theme.of(context).colorScheme.primary, // context is valid here
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        typeLabels[type] ?? type.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => onTypeChanged(val!),
            ),
          ),
          const SizedBox(width: 8),

          // Sort Dropdown
          if (selectedGenreId == null)
            Expanded(
              child: _buildDropdown<String>( // Pass context here
                context, // <--- PASS CONTEXT
                value: selectedSort,
                items: sortOptions.map((key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Row(
                      children: [
                        const Icon(Icons.sort, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sortLabels[key] ?? key,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => onSortChanged(val!),
              ),
            ),
          if (selectedGenreId == null) const SizedBox(width: 8),

          // Genre Dropdown
          Expanded(
            child: _buildDropdown<int?>( // Pass context here
              context, // <--- PASS CONTEXT
              value: selectedGenreId,
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.category_outlined, color: Colors.blueGrey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        allGenresLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ...genres.map<DropdownMenuItem<int?>>((genre) {
                  return DropdownMenuItem<int?>(
                    value: genre.id,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            genre.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (val) => onGenreChanged(val),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to create styled DropdownButton
  // Added BuildContext context parameter
  Widget _buildDropdown<T>(
      BuildContext context, { // <--- ADDED context parameter
        required T value,
        required List<DropdownMenuItem<T>> items,
        required ValueChanged<T?> onChanged,
      }) {
    // Now context is available in this scope
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1), // context is valid
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest, // context is valid
          borderRadius: BorderRadius.circular(12),
          items: items,
          onChanged: onChanged,
          icon: Icon(Icons.arrow_drop_down_rounded, size: 24, color: Theme.of(context).colorScheme.onSurfaceVariant), // context is valid
        ),
      ),
    );
  }
}