import 'package:flutter_test/flutter_test.dart';
import 'package:aurum/data/models/price_movement.dart';
import 'package:aurum/core/utils/currency_formatter.dart';

void main() {
  group('PriceMovement & CurrencyFormatter Tests', () {
    test('PriceMovement identifies positive change correctly', () {
      const movement = PriceMovement(amountChange: 25.50, percentageChange: 0.35);
      expect(movement.isPositive, isTrue);
      expect(movement.isNegative, isFalse);
      expect(movement.isNeutral, isFalse);
      expect(CurrencyFormatter.formatChange(movement.amountChange), '↑ ₹25.50');
      expect(CurrencyFormatter.formatPercentage(movement.percentageChange), '+0.35%');
    });

    test('PriceMovement identifies negative change correctly', () {
      const movement = PriceMovement(amountChange: -18.25, percentageChange: -0.22);
      expect(movement.isPositive, isFalse);
      expect(movement.isNegative, isTrue);
      expect(movement.isNeutral, isFalse);
      expect(CurrencyFormatter.formatChange(movement.amountChange), '↓ ₹18.25');
      expect(CurrencyFormatter.formatPercentage(movement.percentageChange), '-0.22%');
    });

    test('PriceMovement identifies neutral change correctly', () {
      const movement = PriceMovement(amountChange: 0.0, percentageChange: 0.0);
      expect(movement.isPositive, isFalse);
      expect(movement.isNegative, isFalse);
      expect(movement.isNeutral, isTrue);
      expect(CurrencyFormatter.formatChange(movement.amountChange), '— ₹0.00');
      expect(CurrencyFormatter.formatPercentage(movement.percentageChange), '0.00%');
    });

    test('CurrencyFormatter formats Indian Rupees with 2 decimals', () {
      expect(CurrencyFormatter.formatPrice(7250.0), '₹7,250.00');
      expect(CurrencyFormatter.formatPrice(123456.78), '₹1,23,456.78');
    });
  });
}
