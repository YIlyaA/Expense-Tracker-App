import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/l10n/generated/app_localizations.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:flutter/material.dart';

extension AppLocalizationsContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension CategoryTypeX on CategoryType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      CategoryType.food => l10n.categoryFood,
      CategoryType.transport => l10n.categoryTransport,
      CategoryType.phone => l10n.categoryPhone,
      CategoryType.sport => l10n.categorySport,
      CategoryType.household => l10n.categoryHousehold,
      CategoryType.health => l10n.categoryHealth,
      CategoryType.documents => l10n.categoryDocuments,
      CategoryType.clothes => l10n.categoryClothes,
      CategoryType.subscriptions => l10n.categorySubscriptions,
      CategoryType.topUps => l10n.categoryTopUps,
      CategoryType.other => l10n.categoryOther,
    };
  }

  IconData get icon {
    return switch (this) {
      CategoryType.food => Icons.restaurant_outlined,
      CategoryType.transport => Icons.directions_car_outlined,
      CategoryType.phone => Icons.smartphone_outlined,
      CategoryType.sport => Icons.fitness_center_outlined,
      CategoryType.household => Icons.home_outlined,
      CategoryType.health => Icons.favorite_border,
      CategoryType.documents => Icons.description_outlined,
      CategoryType.clothes => Icons.shopping_bag_outlined,
      CategoryType.subscriptions => Icons.menu_book_outlined,
      CategoryType.topUps => Icons.account_balance_wallet_outlined,
      CategoryType.other => Icons.more_horiz,
    };
  }

  Color get color {
    return switch (this) {
      CategoryType.food => AppColors.food,
      CategoryType.transport => AppColors.transport,
      CategoryType.phone => AppColors.phone,
      CategoryType.sport => AppColors.sport,
      CategoryType.household => AppColors.household,
      CategoryType.health => AppColors.health,
      CategoryType.documents => AppColors.documents,
      CategoryType.clothes => AppColors.clothes,
      CategoryType.subscriptions => AppColors.subscriptions,
      CategoryType.topUps => AppColors.topUps,
      CategoryType.other => AppColors.other,
    };
  }

  Color get backgroundColor {
    return switch (this) {
      CategoryType.food => AppColors.foodBg,
      CategoryType.transport => AppColors.transportBg,
      CategoryType.phone => AppColors.phoneBg,
      CategoryType.sport => AppColors.sportBg,
      CategoryType.household => AppColors.householdBg,
      CategoryType.health => AppColors.healthBg,
      CategoryType.documents => AppColors.documentsBg,
      CategoryType.clothes => AppColors.clothesBg,
      CategoryType.subscriptions => AppColors.subscriptionsBg,
      CategoryType.topUps => AppColors.topUpsBg,
      CategoryType.other => AppColors.otherBg,
    };
  }
}

extension CurrencyOptionX on CurrencyOption {
  String label(AppLocalizations l10n) {
    return switch (this) {
      CurrencyOption.pln => l10n.currencyPln,
      CurrencyOption.usd => l10n.currencyUsd,
      CurrencyOption.eur => l10n.currencyEur,
    };
  }

  String get symbol {
    return switch (this) {
      CurrencyOption.pln => 'zł',
      CurrencyOption.usd => r'$',
      CurrencyOption.eur => '€',
    };
  }
}

extension AppTabX on AppTab {
  String label(AppLocalizations l10n) {
    return switch (this) {
      AppTab.dashboard => l10n.homeTab,
      AppTab.transactions => l10n.historyTab,
      AppTab.statistics => l10n.statsTab,
      AppTab.insights => l10n.insightsTab,
      AppTab.settings => l10n.settingsTab,
    };
  }

  IconData get icon {
    return switch (this) {
      AppTab.dashboard => Icons.grid_view_rounded,
      AppTab.transactions => Icons.receipt_long_outlined,
      AppTab.statistics => Icons.pie_chart_outline_rounded,
      AppTab.insights => Icons.lightbulb_outline,
      AppTab.settings => Icons.settings_outlined,
    };
  }
}
