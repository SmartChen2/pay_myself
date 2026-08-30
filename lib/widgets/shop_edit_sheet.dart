import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_palette.dart';
import '../models/shop_item.dart';
import '../i18n/strings.dart';
import '../utils/format.dart';

/// 新建 / 编辑奖励商品弹窗
Future<ShopEdit?> showShopEditSheet(
  BuildContext context, {
  ShopItem? item,
}) {
  final initialName = item != null && item.nameKey != null
      ? context.t(item.nameKey!)
      : item?.name ?? '';
  final initialDesc = item != null && item.descKey != null
      ? context.t(item.descKey!)
      : item?.description ?? '';
  return showModalBottomSheet<ShopEdit>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    enableDrag: true,
    builder: (_) => _ShopEditSheet(item: item, initialName: initialName, initialDesc: initialDesc),
  );
}

class ShopEdit {
  /// null 表示未修改,用于保留 i18n key。
  final String? name;
  final String emoji;
  final String? description;
  final double price;
  final bool delete;
  ShopEdit({
    this.name,
    required this.emoji,
    this.description,
    required this.price,
    this.delete = false,
  });
}

class _ShopEditSheet extends StatefulWidget {
  final ShopItem? item;
  final String initialName;
  final String initialDesc;
  const _ShopEditSheet({this.item, required this.initialName, required this.initialDesc});

  @override
  State<_ShopEditSheet> createState() => _ShopEditSheetState();
}

class _ShopEditSheetState extends State<_ShopEditSheet> {
  late final TextEditingController _name;
  late final TextEditingController _emoji;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  bool get _isEdit => widget.item != null;

  static const _emojiPresets = ['🎁', '☕', '🍫', '🎮', '🎬', '📚', '🍜', '💆', '👕', '🍰', '🧋', '🛍️'];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _emoji = TextEditingController(text: widget.item?.emoji ?? '🎁');
    _desc = TextEditingController(text: widget.initialDesc);
    _price = TextEditingController(
      text: widget.item == null ? '' : widget.item!.price.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _emoji.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  void _submit({bool delete = false}) {
    final name = _name.text.trim();
    final emoji = _emoji.text.trim().isEmpty ? '🎁' : _emoji.text.trim();
    final price = double.tryParse(_price.text.trim()) ?? 0;
    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('shop.edit.invalid'))),
      );
      return;
    }
    final rawDesc = _desc.text.trim().isEmpty ? context.t('shop.edit.desc.default') : _desc.text.trim();
    // 名称/描述未改时传 null,保留 i18n key。
    final nameUnchanged = _isEdit && name == widget.initialName;
    final descUnchanged = _isEdit && rawDesc == widget.initialDesc;
    Navigator.of(context).pop(ShopEdit(
      name: nameUnchanged ? null : name,
      emoji: emoji,
      description: descUnchanged ? null : rawDesc,
      price: price,
      delete: delete,
    ));
  }

  TextStyle _labelStyle(AppPalette p) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: p.mutedForeground,
      );

  InputDecoration _decoration(AppPalette p, {String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.mutedForeground),
        filled: true,
        fillColor: p.input,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusMd)),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final padBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: AppShadows.shadow2,
        ),
        padding: EdgeInsets.fromLTRB(20, 24, 20, (padBottom + 32).clamp(32, 64)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: p.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                _isEdit ? context.t('shop.edit.edit') : context.t('shop.edit.new'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: p.foreground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(context.t('shop.edit.icon'), style: _labelStyle(p)),
              const SizedBox(height: 8),
              TextField(
                controller: _emoji,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.foreground, fontSize: 22),
                decoration: _decoration(p, hint: '🎁'),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in _emojiPresets)
                    GestureDetector(
                      onTap: () => setState(() => _emoji.text = e),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _emoji.text == e ? p.goldSoft : p.input,
                          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                          border: Border.all(
                            color: _emoji.text == e ? p.gold : p.border,
                          ),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(context.t('shop.edit.name'), style: _labelStyle(p)),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: p.foreground),
                decoration: _decoration(p, hint: context.t('shop.edit.name.hint')),
              ),
              const SizedBox(height: 16),
              Text(context.t('shop.edit.desc'), style: _labelStyle(p)),
              const SizedBox(height: 8),
              TextField(
                controller: _desc,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: p.foreground),
                decoration: _decoration(p, hint: context.t('shop.edit.desc.hint')),
              ),
              const SizedBox(height: 16),
              Text(context.t('shop.edit.price'), style: _labelStyle(p)),
              const SizedBox(height: 8),
              TextField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: p.foreground),
                decoration: _decoration(p, hint: context.t('shop.edit.price.hint')).copyWith(
                  prefixText: Format.currencySymbol,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _submit(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: p.gold,
                  foregroundColor: p.foreground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(_isEdit ? context.t('shop.edit.save') : context.t('shop.edit.add')),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: p.card,
                        title: Text(context.t('shop.edit.delete.title'), style: TextStyle(color: p.foreground)),
                        content: Text(
                          context.t('shop.edit.delete.msg', [widget.initialName]),
                          style: TextStyle(color: p.mutedForeground),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(context.t('shop.edit.cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: AppTokens.error),
                            child: Text(context.t('shop.edit.delete.confirm')),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) _submit(delete: true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTokens.error,
                  ),
                  child: Text(context.t('shop.edit.delete.btn')),
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: p.mutedForeground,
                ),
                child: Text(context.t('shop.edit.cancel')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
