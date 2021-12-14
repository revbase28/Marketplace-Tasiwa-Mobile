import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_deals_repository.dart';
import 'package:zcart/data/repository/deals_repository.dart';
import 'package:zcart/riverpod/notifier/deals_state_notifier.dart';
import 'package:zcart/riverpod/state/deals_state.dart';

final dealsRepositoryProvider =
    Provider<IDealsRepository>((ref) => DealsRepository());

final dealsUnderThePriceNotifierProvider =
    StateNotifierProvider<DealsUnderThePriceNotifier, DealsUnderThePriceState>(
        (ref) =>
            DealsUnderThePriceNotifier(ref.watch(dealsRepositoryProvider)));

final dealOfThedayNotifierProvider =
    StateNotifierProvider<DealOfTheDayNotifier, DealOfTheDayState>(
        (ref) => DealOfTheDayNotifier(ref.watch(dealsRepositoryProvider)));
