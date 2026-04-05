import 'package:calinout/core/presentation/extensions/doodle_card_list_item_extension.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_content.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_dimensions.dart';
import 'package:calinout/core/presentation/widgets/double_back_card/doodle_card_dimensions_extension.dart';
import 'package:calinout/features/food_type_library/domain/entities/food_type.dart';
import 'package:calinout/features/food_type_library/presentation/controllers/food_type_controller.dart';
import 'package:calinout/features/food_type_library/presentation/widgets/food_type_detail_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Assume FoodTypeForm is imported from previous step or similar

class FoodTypePage extends ConsumerStatefulWidget {
  const FoodTypePage({super.key});

  @override
  ConsumerState<FoodTypePage> createState() => _FoodTypePageState();
}

class _FoodTypePageState extends ConsumerState<FoodTypePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(foodTypeControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(foodTypeControllerProvider);

    final dimensions = context.doodleCardResponsive;

    final isFetchingMore = ref.watch(foodTypeIsFetchingMoreProvider);

    return Column(
      children: [
        // Search Bar
        const Padding(padding: EdgeInsets.all(16.0), child: _SearchBarHeader()),

        // The List Area
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(foodTypeControllerProvider),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                asyncState.when(
                  data: (state) {
                    if (state!.items.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: Text("No food types found.")),
                      );
                    }
                    return SliverPadding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal:
                            (dimensions.screenWidth -
                                dimensions.listHeaderWidth) /
                            2,
                      ),
                      sliver: _buildSliverList(state.items, dimensions),
                    );
                  },
                  error: (err, stack) => SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(err.toString()),
                          TextButton(
                            onPressed: () =>
                                ref.invalidate(foodTypeControllerProvider),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),

                // Bottom Loading Indicator (for pagination)
                if (isFetchingMore && asyncState.hasValue)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverList(
    List<FoodType> items,
    DoodleCardDimensions dimensions,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsetsGeometry.only(bottom: 10),
          child: DoodleCard.listItemShapeFoodType(
            width: dimensions.listItemCardWidth,

            onTap: () => showFoodTypeDetailDialog(
              context: context,
              ref: ref,
              foodType: items[index],
            ),
            child: DoodleCardListItem(
              variant: DoodleCardListItemVariant.foodType,
              dimensions: dimensions,
              data: items[index].toDoodleCardListItem(),
            ),
          ),
        ),
        childCount: items.length,
      ),
    );
  }
}

class _SearchBarHeader extends ConsumerStatefulWidget {
  const _SearchBarHeader();

  @override
  ConsumerState<_SearchBarHeader> createState() => _SearchBarHeaderState();
}

class _SearchBarHeaderState extends ConsumerState<_SearchBarHeader> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: _controller,
      hintText: "Search food...",
      leading: const Icon(Icons.search),
      onChanged: (val) =>
          ref.read(foodTypeSearchQueryProvider.notifier).setQuery(val),
      elevation: WidgetStateProperty.all(1),
    );
  }
}
