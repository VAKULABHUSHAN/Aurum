import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';
import 'package:aurum/data/models/price_movement.dart';
import 'package:aurum/data/models/chart_range.dart';
import 'package:aurum/features/home/views/widgets/main_price_card.dart';
import 'package:aurum/features/home/views/widgets/secondary_price_card.dart';
import 'package:aurum/features/home/views/widgets/price_movement_badge.dart';
import 'package:aurum/features/home/views/widgets/price_history_card.dart';

void main() {
  final sampleGoldPrice = IndianGoldRateModel(
    price24kPerGram: 8450.50,
    price22kPerGram: 7746.29,
    price18kPerGram: 6337.88,
    timestamp: '2026-08-09T10:30:00Z',
    source: 'IBJA Benchmark',
    unit: 'INR/g',
    session: 'AM',
    rateDate: '2026-08-09',
  );

  group('Widget Tests', () {
    testWidgets('MainPriceCard displays 24K price, per gram, timestamp and IBJA label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainPriceCard(
              priceData: sampleGoldPrice,
              movement: const PriceMovement(amountChange: 15.0, percentageChange: 0.18),
              lastUpdated: '10:30 AM',
              isOffline: false,
            ),
          ),
        ),
      );

      expect(find.text('24K Gold • India'), findsOneWidget);
      expect(find.text('₹8,450.50'), findsOneWidget);
      expect(find.text('per gram'), findsOneWidget);
      expect(find.text('Updated at 10:30 AM'), findsOneWidget);
      expect(find.text('IBJA Benchmark · Indicative'), findsOneWidget);
      expect(find.text('↑ ₹15.00 (+0.18%)'), findsOneWidget);
      expect(find.text('Offline Data'), findsNothing);
    });

    testWidgets('MainPriceCard displays Offline Data badge when offline is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainPriceCard(
              priceData: sampleGoldPrice,
              movement: null,
              lastUpdated: '10:30 AM',
              isOffline: true,
            ),
          ),
        ),
      );

      expect(find.text('Offline Data'), findsOneWidget);
      expect(find.byType(PriceMovementBadge), findsNothing);
    });

    testWidgets('SecondaryPriceCard displays 22K price and per gram', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryPriceCard(
              priceData: sampleGoldPrice,
            ),
          ),
        ),
      );

      expect(find.text('22K Gold • India'), findsOneWidget);
      expect(find.text('₹7,746.29'), findsOneWidget);
      expect(find.text('per gram'), findsOneWidget);
    });

    testWidgets('PriceHistoryCard shows empty state when fewer than 2 records', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PriceHistoryCard(
              history: [
                sampleGoldPrice,
              ],
              selectedRange: ChartRange.week7d,
              onRangeSelected: (_) {},
              highPrice: null,
              lowPrice: null,
            ),
          ),
        ),
      );

      expect(find.text('Price History'), findsOneWidget);
      expect(find.text('7D'), findsOneWidget);
      expect(find.text('30D'), findsOneWidget);
      expect(find.text('24H'), findsNothing);
      expect(find.text('Building price history...'), findsOneWidget);
      expect(find.text('Chart will appear when more data points are collected locally.'), findsOneWidget);
      expect(find.text('High  '), findsNothing);
    });

    testWidgets('PriceHistoryCard shows chart and High/Low when >= 2 records', (WidgetTester tester) async {
      final sampleGoldPrice2 = IndianGoldRateModel(
        price24kPerGram: 8480.00,
        price22kPerGram: 7746.29,
        price18kPerGram: 6337.88,
        timestamp: '2026-08-09T10:30:00Z',
        source: 'IBJA Benchmark',
        unit: 'INR/g',
        session: 'PM',
        rateDate: '2026-08-09',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PriceHistoryCard(
                history: [
                  sampleGoldPrice,
                  sampleGoldPrice2,
                ],
                selectedRange: ChartRange.week7d,
                onRangeSelected: (_) {},
                highPrice: 8480.0,
                lowPrice: 8450.5,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Price History'), findsOneWidget);
      expect(find.text('High  '), findsOneWidget);
      expect(find.text('₹8,480.00'), findsOneWidget);
      expect(find.text('Low  '), findsOneWidget);
      expect(find.text('₹8,450.50'), findsOneWidget);
      expect(find.text('Building price history...'), findsNothing);
    });
  });
}
