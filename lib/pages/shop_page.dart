import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../state/app_state_scope.dart';
import '../state/app_state.dart';
import '../utils/format.dart';
import '../models/shop_item.dart';
import '../widgets/status_bar.dart';
import '../widgets/icons.dart';
import '../widgets/shop_edit_sheet.dart';
import '../i18n/strings.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final p = AppPalette.of(context);
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            const IosStatusBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                children: [
                  // header
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t('shop.title'),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: p.foreground,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.t('shop.subtitle'),
                          style: TextStyle(
                            fontSize: 13,
                            color: p.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // balance card
                  _BalanceCard(
                    p: p,
                    balance: state.balance,
                    purchaseCount: state.purchaseCount,
                  ),
                  const SizedBox(height: 22),
                  // section title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.t('shop.rewards'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: p.mutedForeground,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.t('shop.items.n', ['${state.shopItems.length}']),
                            style: TextStyle(
                              fontSize: 12,
                              color: p.mutedForeground,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _AddButton(p: p, onTap: () => _addItem(context, state)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                    children: [
                      for (final it in state.shopItems)
                        _ShopCard(
                          p: p,
                          item: it,
                          owned: state.ownsItem(it.id),
                          affordable: state.balance >= it.price,
                          onBuy: () => _buy(context, state, it),
                          onEdit: () => _editItem(context, state, it),
                        ),
                    ],
                  ),
                  if (state.purchases.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _RecentPurchases(p: p, purchases: state.purchases),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem(BuildContext context, AppState state) async {
    final res = await showShopEditSheet(context);
    if (res == null || res.delete || res.name == null || res.description == null) return;
    state.addShopItem(
      name: res.name!,
      emoji: res.emoji,
      description: res.description!,
      price: res.price,
    );
  }

  void _editItem(BuildContext context, AppState state, ShopItem item) async {
    final res = await showShopEditSheet(context, item: item);
    if (res == null) return;
    if (res.delete) {
      state.removeShopItem(item.id);
      return;
    }
    state.updateShopItem(
      item.id,
      name: res.name,
      emoji: res.emoji,
      description: res.description,
      price: res.price,
    );
  }

  void _buy(BuildContext context, AppState state, ShopItem item) async {
    final p = AppPalette.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.card,
        title: Text(context.t('shop.redeem.title', [item.name]), style: TextStyle(color: p.foreground)),
        content: Text(
          context.t('shop.redeem.msg', [Format.yuan(item.price), item.name]),
          style: TextStyle(color: p.mutedForeground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t('shop.edit.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: p.gold,
              foregroundColor: p.foreground,
            ),
            child: Text(context.t('shop.redeem')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final success = state.purchase(item);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? context.t('shop.success', [item.emoji, item.name])
            : context.t('shop.insufficient')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? AppTokens.success : p.mutedForeground,
      ),
    );
  }
}

/// 余额卡
class _BalanceCard extends StatelessWidget {
  final AppPalette p;
  final double balance;
  final int purchaseCount;
  const _BalanceCard({required this.p, required this.balance, required this.purchaseCount});

  @override
  Widget build(BuildContext context) {
    // 金色渐变背景上的文字色：两种模式都用近黑（亮金背景上深字才有对比）
    // dark 模式下金色更亮，深字反而更清晰
    const onGold = Color(0xFF1F1408);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.gold, p.goldLight],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: AppShadows.shadowGold,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CoinIcon(size: 18, color: onGold, darkColor: onGold),
              const SizedBox(width: 6),
              Text(
                context.t('shop.available'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onGold,
                ),
              ),
              const Spacer(),
              if (purchaseCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: onGold.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.t('shop.purchased.n', ['$purchaseCount']),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: onGold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            Format.yuan(balance),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: onGold,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// 商品卡
class _ShopCard extends StatelessWidget {
  final AppPalette p;
  final ShopItem item;
  final bool owned;
  final bool affordable;
  final VoidCallback onBuy;
  final VoidCallback onEdit;
  const _ShopCard({
    required this.p,
    required this.item,
    required this.owned,
    required this.affordable,
    required this.onBuy,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: owned ? p.goldSoft : p.border),
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // emoji icon
          Center(
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.goldSoft,
                shape: BoxShape.circle,
              ),
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              item.nameKey != null ? context.t(item.nameKey!) : item.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: p.cardForeground,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Center(
            child: Text(
              item.descKey != null ? context.t(item.descKey!) : item.description,
              style: TextStyle(
                fontSize: 11,
                color: p.mutedForeground,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 8),
          // price + button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CoinIcon(size: 14),
                  const SizedBox(width: 3),
                  Text(
                    Format.num2(item.price),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.gold,
                    ),
                  ),
                ],
              ),
              _BuyButton(
                p: p,
                owned: owned,
                affordable: affordable,
                onTap: onBuy,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  final AppPalette p;
  final bool owned;
  final bool affordable;
  final VoidCallback onTap;
  const _BuyButton({
    required this.p,
    required this.owned,
    required this.affordable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = !owned && affordable;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: owned
              ? p.goldSoft
              : (affordable ? p.gold : p.muted),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          owned ? context.t('shop.owned') : (affordable ? context.t('shop.redeem') : context.t('shop.need.more')),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: owned
                ? p.gold
                : (affordable ? p.foreground : p.mutedForeground),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final AppPalette p;
  final VoidCallback onTap;
  const _AddButton({required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: p.gold,
          shape: BoxShape.circle,
          boxShadow: AppShadows.shadowGold,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }
}

/// 最近兑换
class _RecentPurchases extends StatelessWidget {
  final AppPalette p;
  final List<Purchase> purchases;
  const _RecentPurchases({required this.p, required this.purchases});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('shop.recent'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: p.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        for (final pur in purchases.take(4)) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: p.card,
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: Row(
              children: [
                Text(pur.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pur.itemName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: p.cardForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${Format.date(pur.at)} ${Format.time(pur.at)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: p.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '-${Format.yuan(pur.price)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTokens.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
