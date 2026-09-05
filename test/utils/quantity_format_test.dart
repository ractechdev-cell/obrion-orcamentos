import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/utils/quantity_format.dart';

void main() {
  group('formatQuantity', () {
    test('inteiro sai sem vírgula nem zero', () {
      expect(formatQuantity(6), '6');
      expect(formatQuantity(40), '40');
      expect(formatQuantity(1000.0), '1000');
    });

    test('só uma casa decimal limpa o zero final', () {
      expect(formatQuantity(12.5), '12,5');
      expect(formatQuantity(0.5), '0,5');
    });

    test('duas casas preserva o centavo', () {
      expect(formatQuantity(12.75), '12,75');
      expect(formatQuantity(1.02), '1,02');
    });

    test('zero vira "0"', () {
      expect(formatQuantity(0), '0');
    });

    test('décimos que não viram zero final ficam íntegros', () {
      expect(formatQuantity(2.01), '2,01');
    });

    test('3-4 casas de medidas preservadas (conta do cliente fecha)', () {
      expect(formatQuantity(46.256), '46,256');
      expect(formatQuantity(46.2563), '46,2563');
    });

    test('negativo sane sem perder casa', () {
      expect(formatQuantity(-12.5), '-12,5');
    });

    test('1.0001 não apaga o 1 final', () {
      expect(formatQuantity(1.0001), '1,0001');
    });
  });
}