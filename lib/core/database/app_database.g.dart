// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAvailableMeta = const VerificationMeta(
    'isAvailable',
  );
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
    'is_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    categoryId,
    sku,
    barcode,
    price,
    isAvailable,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('is_available')) {
      context.handle(
        _isAvailableMeta,
        isAvailable.isAcceptableOrUnknown(
          data['is_available']!,
          _isAvailableMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      isAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_available'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String name;
  final String? categoryId;
  final String? sku;
  final String? barcode;
  final double price;
  final bool isAvailable;
  const Product({
    required this.id,
    required this.name,
    this.categoryId,
    this.sku,
    this.barcode,
    required this.price,
    required this.isAvailable,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['price'] = Variable<double>(price);
    map['is_available'] = Variable<bool>(isAvailable);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      price: Value(price),
      isAvailable: Value(isAvailable),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      sku: serializer.fromJson<String?>(json['sku']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      price: serializer.fromJson<double>(json['price']),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<String?>(categoryId),
      'sku': serializer.toJson<String?>(sku),
      'barcode': serializer.toJson<String?>(barcode),
      'price': serializer.toJson<double>(price),
      'isAvailable': serializer.toJson<bool>(isAvailable),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> sku = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    double? price,
    bool? isAvailable,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    sku: sku.present ? sku.value : this.sku,
    barcode: barcode.present ? barcode.value : this.barcode,
    price: price ?? this.price,
    isAvailable: isAvailable ?? this.isAvailable,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      sku: data.sku.present ? data.sku.value : this.sku,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      price: data.price.present ? data.price.value : this.price,
      isAvailable: data.isAvailable.present
          ? data.isAvailable.value
          : this.isAvailable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('price: $price, ')
          ..write('isAvailable: $isAvailable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, categoryId, sku, barcode, price, isAvailable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.sku == this.sku &&
          other.barcode == this.barcode &&
          other.price == this.price &&
          other.isAvailable == this.isAvailable);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> categoryId;
  final Value<String?> sku;
  final Value<String?> barcode;
  final Value<double> price;
  final Value<bool> isAvailable;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.price = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    this.categoryId = const Value.absent(),
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    required double price,
    this.isAvailable = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       price = Value(price);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? categoryId,
    Expression<String>? sku,
    Expression<String>? barcode,
    Expression<double>? price,
    Expression<bool>? isAvailable,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (price != null) 'price': price,
      if (isAvailable != null) 'is_available': isAvailable,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? categoryId,
    Value<String?>? sku,
    Value<String?>? barcode,
    Value<double>? price,
    Value<bool>? isAvailable,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('price: $price, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VariantsTable extends Variants with TableInfo<$VariantsTable, Variant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VariantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceAdjustmentMeta = const VerificationMeta(
    'priceAdjustment',
  );
  @override
  late final GeneratedColumn<double> priceAdjustment = GeneratedColumn<double>(
    'price_adjustment',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, productId, name, priceAdjustment];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'variants';
  @override
  VerificationContext validateIntegrity(
    Insertable<Variant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price_adjustment')) {
      context.handle(
        _priceAdjustmentMeta,
        priceAdjustment.isAcceptableOrUnknown(
          data['price_adjustment']!,
          _priceAdjustmentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Variant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Variant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      priceAdjustment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_adjustment'],
      )!,
    );
  }

  @override
  $VariantsTable createAlias(String alias) {
    return $VariantsTable(attachedDatabase, alias);
  }
}

class Variant extends DataClass implements Insertable<Variant> {
  final String id;
  final String productId;
  final String name;
  final double priceAdjustment;
  const Variant({
    required this.id,
    required this.productId,
    required this.name,
    required this.priceAdjustment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['name'] = Variable<String>(name);
    map['price_adjustment'] = Variable<double>(priceAdjustment);
    return map;
  }

  VariantsCompanion toCompanion(bool nullToAbsent) {
    return VariantsCompanion(
      id: Value(id),
      productId: Value(productId),
      name: Value(name),
      priceAdjustment: Value(priceAdjustment),
    );
  }

  factory Variant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Variant(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      priceAdjustment: serializer.fromJson<double>(json['priceAdjustment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'name': serializer.toJson<String>(name),
      'priceAdjustment': serializer.toJson<double>(priceAdjustment),
    };
  }

  Variant copyWith({
    String? id,
    String? productId,
    String? name,
    double? priceAdjustment,
  }) => Variant(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    name: name ?? this.name,
    priceAdjustment: priceAdjustment ?? this.priceAdjustment,
  );
  Variant copyWithCompanion(VariantsCompanion data) {
    return Variant(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      priceAdjustment: data.priceAdjustment.present
          ? data.priceAdjustment.value
          : this.priceAdjustment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Variant(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('priceAdjustment: $priceAdjustment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, name, priceAdjustment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Variant &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.priceAdjustment == this.priceAdjustment);
}

class VariantsCompanion extends UpdateCompanion<Variant> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> name;
  final Value<double> priceAdjustment;
  final Value<int> rowid;
  const VariantsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.priceAdjustment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VariantsCompanion.insert({
    required String id,
    required String productId,
    required String name,
    this.priceAdjustment = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       name = Value(name);
  static Insertable<Variant> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? name,
    Expression<double>? priceAdjustment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (priceAdjustment != null) 'price_adjustment': priceAdjustment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VariantsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? name,
    Value<double>? priceAdjustment,
    Value<int>? rowid,
  }) {
    return VariantsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (priceAdjustment.present) {
      map['price_adjustment'] = Variable<double>(priceAdjustment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VariantsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('priceAdjustment: $priceAdjustment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoriesTable extends Inventories
    with TableInfo<$InventoriesTable, Inventory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<double> stock = GeneratedColumn<double>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [productId, stock];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Inventory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId};
  @override
  Inventory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Inventory(
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock'],
      )!,
    );
  }

  @override
  $InventoriesTable createAlias(String alias) {
    return $InventoriesTable(attachedDatabase, alias);
  }
}

class Inventory extends DataClass implements Insertable<Inventory> {
  final String productId;
  final double stock;
  const Inventory({required this.productId, required this.stock});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['stock'] = Variable<double>(stock);
    return map;
  }

  InventoriesCompanion toCompanion(bool nullToAbsent) {
    return InventoriesCompanion(
      productId: Value(productId),
      stock: Value(stock),
    );
  }

  factory Inventory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Inventory(
      productId: serializer.fromJson<String>(json['productId']),
      stock: serializer.fromJson<double>(json['stock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'stock': serializer.toJson<double>(stock),
    };
  }

  Inventory copyWith({String? productId, double? stock}) => Inventory(
    productId: productId ?? this.productId,
    stock: stock ?? this.stock,
  );
  Inventory copyWithCompanion(InventoriesCompanion data) {
    return Inventory(
      productId: data.productId.present ? data.productId.value : this.productId,
      stock: data.stock.present ? data.stock.value : this.stock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Inventory(')
          ..write('productId: $productId, ')
          ..write('stock: $stock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(productId, stock);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Inventory &&
          other.productId == this.productId &&
          other.stock == this.stock);
}

class InventoriesCompanion extends UpdateCompanion<Inventory> {
  final Value<String> productId;
  final Value<double> stock;
  final Value<int> rowid;
  const InventoriesCompanion({
    this.productId = const Value.absent(),
    this.stock = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoriesCompanion.insert({
    required String productId,
    this.stock = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productId = Value(productId);
  static Insertable<Inventory> custom({
    Expression<String>? productId,
    Expression<double>? stock,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (stock != null) 'stock': stock,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoriesCompanion copyWith({
    Value<String>? productId,
    Value<double>? stock,
    Value<int>? rowid,
  }) {
    return InventoriesCompanion(
      productId: productId ?? this.productId,
      stock: stock ?? this.stock,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (stock.present) {
      map['stock'] = Variable<double>(stock.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoriesCompanion(')
          ..write('productId: $productId, ')
          ..write('stock: $stock, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentMethodsTable extends PaymentMethods
    with TableInfo<$PaymentMethodsTable, PaymentMethod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentMethodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_methods';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentMethod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentMethod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentMethod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $PaymentMethodsTable createAlias(String alias) {
    return $PaymentMethodsTable(attachedDatabase, alias);
  }
}

class PaymentMethod extends DataClass implements Insertable<PaymentMethod> {
  final String id;
  final String name;
  final String type;
  final bool isActive;
  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  PaymentMethodsCompanion toCompanion(bool nullToAbsent) {
    return PaymentMethodsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      isActive: Value(isActive),
    );
  }

  factory PaymentMethod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentMethod(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  PaymentMethod copyWith({
    String? id,
    String? name,
    String? type,
    bool? isActive,
  }) => PaymentMethod(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    isActive: isActive ?? this.isActive,
  );
  PaymentMethod copyWithCompanion(PaymentMethodsCompanion data) {
    return PaymentMethod(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethod(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentMethod &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.isActive == this.isActive);
}

class PaymentMethodsCompanion extends UpdateCompanion<PaymentMethod> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<bool> isActive;
  final Value<int> rowid;
  const PaymentMethodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentMethodsCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type);
  static Insertable<PaymentMethod> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentMethodsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return PaymentMethodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutletSettingsTable extends OutletSettings
    with TableInfo<$OutletSettingsTable, OutletSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutletSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxPercentageMeta = const VerificationMeta(
    'taxPercentage',
  );
  @override
  late final GeneratedColumn<double> taxPercentage = GeneratedColumn<double>(
    'tax_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _serviceChargePercentageMeta =
      const VerificationMeta('serviceChargePercentage');
  @override
  late final GeneratedColumn<double> serviceChargePercentage =
      GeneratedColumn<double>(
        'service_charge_percentage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _printerMacAddressMeta = const VerificationMeta(
    'printerMacAddress',
  );
  @override
  late final GeneratedColumn<String> printerMacAddress =
      GeneratedColumn<String>(
        'printer_mac_address',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taxPercentage,
    serviceChargePercentage,
    printerMacAddress,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outlet_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutletSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tax_percentage')) {
      context.handle(
        _taxPercentageMeta,
        taxPercentage.isAcceptableOrUnknown(
          data['tax_percentage']!,
          _taxPercentageMeta,
        ),
      );
    }
    if (data.containsKey('service_charge_percentage')) {
      context.handle(
        _serviceChargePercentageMeta,
        serviceChargePercentage.isAcceptableOrUnknown(
          data['service_charge_percentage']!,
          _serviceChargePercentageMeta,
        ),
      );
    }
    if (data.containsKey('printer_mac_address')) {
      context.handle(
        _printerMacAddressMeta,
        printerMacAddress.isAcceptableOrUnknown(
          data['printer_mac_address']!,
          _printerMacAddressMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutletSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutletSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taxPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_percentage'],
      )!,
      serviceChargePercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}service_charge_percentage'],
      )!,
      printerMacAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printer_mac_address'],
      ),
    );
  }

  @override
  $OutletSettingsTable createAlias(String alias) {
    return $OutletSettingsTable(attachedDatabase, alias);
  }
}

class OutletSetting extends DataClass implements Insertable<OutletSetting> {
  final String id;
  final double taxPercentage;
  final double serviceChargePercentage;
  final String? printerMacAddress;
  const OutletSetting({
    required this.id,
    required this.taxPercentage,
    required this.serviceChargePercentage,
    this.printerMacAddress,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tax_percentage'] = Variable<double>(taxPercentage);
    map['service_charge_percentage'] = Variable<double>(
      serviceChargePercentage,
    );
    if (!nullToAbsent || printerMacAddress != null) {
      map['printer_mac_address'] = Variable<String>(printerMacAddress);
    }
    return map;
  }

  OutletSettingsCompanion toCompanion(bool nullToAbsent) {
    return OutletSettingsCompanion(
      id: Value(id),
      taxPercentage: Value(taxPercentage),
      serviceChargePercentage: Value(serviceChargePercentage),
      printerMacAddress: printerMacAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(printerMacAddress),
    );
  }

  factory OutletSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutletSetting(
      id: serializer.fromJson<String>(json['id']),
      taxPercentage: serializer.fromJson<double>(json['taxPercentage']),
      serviceChargePercentage: serializer.fromJson<double>(
        json['serviceChargePercentage'],
      ),
      printerMacAddress: serializer.fromJson<String?>(
        json['printerMacAddress'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taxPercentage': serializer.toJson<double>(taxPercentage),
      'serviceChargePercentage': serializer.toJson<double>(
        serviceChargePercentage,
      ),
      'printerMacAddress': serializer.toJson<String?>(printerMacAddress),
    };
  }

  OutletSetting copyWith({
    String? id,
    double? taxPercentage,
    double? serviceChargePercentage,
    Value<String?> printerMacAddress = const Value.absent(),
  }) => OutletSetting(
    id: id ?? this.id,
    taxPercentage: taxPercentage ?? this.taxPercentage,
    serviceChargePercentage:
        serviceChargePercentage ?? this.serviceChargePercentage,
    printerMacAddress: printerMacAddress.present
        ? printerMacAddress.value
        : this.printerMacAddress,
  );
  OutletSetting copyWithCompanion(OutletSettingsCompanion data) {
    return OutletSetting(
      id: data.id.present ? data.id.value : this.id,
      taxPercentage: data.taxPercentage.present
          ? data.taxPercentage.value
          : this.taxPercentage,
      serviceChargePercentage: data.serviceChargePercentage.present
          ? data.serviceChargePercentage.value
          : this.serviceChargePercentage,
      printerMacAddress: data.printerMacAddress.present
          ? data.printerMacAddress.value
          : this.printerMacAddress,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutletSetting(')
          ..write('id: $id, ')
          ..write('taxPercentage: $taxPercentage, ')
          ..write('serviceChargePercentage: $serviceChargePercentage, ')
          ..write('printerMacAddress: $printerMacAddress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taxPercentage,
    serviceChargePercentage,
    printerMacAddress,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutletSetting &&
          other.id == this.id &&
          other.taxPercentage == this.taxPercentage &&
          other.serviceChargePercentage == this.serviceChargePercentage &&
          other.printerMacAddress == this.printerMacAddress);
}

class OutletSettingsCompanion extends UpdateCompanion<OutletSetting> {
  final Value<String> id;
  final Value<double> taxPercentage;
  final Value<double> serviceChargePercentage;
  final Value<String?> printerMacAddress;
  final Value<int> rowid;
  const OutletSettingsCompanion({
    this.id = const Value.absent(),
    this.taxPercentage = const Value.absent(),
    this.serviceChargePercentage = const Value.absent(),
    this.printerMacAddress = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutletSettingsCompanion.insert({
    required String id,
    this.taxPercentage = const Value.absent(),
    this.serviceChargePercentage = const Value.absent(),
    this.printerMacAddress = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<OutletSetting> custom({
    Expression<String>? id,
    Expression<double>? taxPercentage,
    Expression<double>? serviceChargePercentage,
    Expression<String>? printerMacAddress,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taxPercentage != null) 'tax_percentage': taxPercentage,
      if (serviceChargePercentage != null)
        'service_charge_percentage': serviceChargePercentage,
      if (printerMacAddress != null) 'printer_mac_address': printerMacAddress,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutletSettingsCompanion copyWith({
    Value<String>? id,
    Value<double>? taxPercentage,
    Value<double>? serviceChargePercentage,
    Value<String?>? printerMacAddress,
    Value<int>? rowid,
  }) {
    return OutletSettingsCompanion(
      id: id ?? this.id,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      serviceChargePercentage:
          serviceChargePercentage ?? this.serviceChargePercentage,
      printerMacAddress: printerMacAddress ?? this.printerMacAddress,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taxPercentage.present) {
      map['tax_percentage'] = Variable<double>(taxPercentage.value);
    }
    if (serviceChargePercentage.present) {
      map['service_charge_percentage'] = Variable<double>(
        serviceChargePercentage.value,
      );
    }
    if (printerMacAddress.present) {
      map['printer_mac_address'] = Variable<String>(printerMacAddress.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutletSettingsCompanion(')
          ..write('id: $id, ')
          ..write('taxPercentage: $taxPercentage, ')
          ..write('serviceChargePercentage: $serviceChargePercentage, ')
          ..write('printerMacAddress: $printerMacAddress, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, Shift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outletIdMeta = const VerificationMeta(
    'outletId',
  );
  @override
  late final GeneratedColumn<String> outletId = GeneratedColumn<String>(
    'outlet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftNumberMeta = const VerificationMeta(
    'shiftNumber',
  );
  @override
  late final GeneratedColumn<int> shiftNumber = GeneratedColumn<int>(
    'shift_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingCashMeta = const VerificationMeta(
    'openingCash',
  );
  @override
  late final GeneratedColumn<double> openingCash = GeneratedColumn<double>(
    'opening_cash',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closingCashMeta = const VerificationMeta(
    'closingCash',
  );
  @override
  late final GeneratedColumn<double> closingCash = GeneratedColumn<double>(
    'closing_cash',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedCashMeta = const VerificationMeta(
    'expectedCash',
  );
  @override
  late final GeneratedColumn<double> expectedCash = GeneratedColumn<double>(
    'expected_cash',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalSalesMeta = const VerificationMeta(
    'totalSales',
  );
  @override
  late final GeneratedColumn<double> totalSales = GeneratedColumn<double>(
    'total_sales',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    outletId,
    userId,
    shiftNumber,
    openingCash,
    closingCash,
    expectedCash,
    totalSales,
    status,
    openedAt,
    closedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shift> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('outlet_id')) {
      context.handle(
        _outletIdMeta,
        outletId.isAcceptableOrUnknown(data['outlet_id']!, _outletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outletIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('shift_number')) {
      context.handle(
        _shiftNumberMeta,
        shiftNumber.isAcceptableOrUnknown(
          data['shift_number']!,
          _shiftNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shiftNumberMeta);
    }
    if (data.containsKey('opening_cash')) {
      context.handle(
        _openingCashMeta,
        openingCash.isAcceptableOrUnknown(
          data['opening_cash']!,
          _openingCashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingCashMeta);
    }
    if (data.containsKey('closing_cash')) {
      context.handle(
        _closingCashMeta,
        closingCash.isAcceptableOrUnknown(
          data['closing_cash']!,
          _closingCashMeta,
        ),
      );
    }
    if (data.containsKey('expected_cash')) {
      context.handle(
        _expectedCashMeta,
        expectedCash.isAcceptableOrUnknown(
          data['expected_cash']!,
          _expectedCashMeta,
        ),
      );
    }
    if (data.containsKey('total_sales')) {
      context.handle(
        _totalSalesMeta,
        totalSales.isAcceptableOrUnknown(data['total_sales']!, _totalSalesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shift(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      outletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outlet_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      shiftNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shift_number'],
      )!,
      openingCash: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opening_cash'],
      )!,
      closingCash: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}closing_cash'],
      ),
      expectedCash: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_cash'],
      ),
      totalSales: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_sales'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class Shift extends DataClass implements Insertable<Shift> {
  final String id;
  final String outletId;
  final String userId;
  final int shiftNumber;
  final double openingCash;
  final double? closingCash;
  final double? expectedCash;
  final double? totalSales;
  final String status;
  final DateTime openedAt;
  final DateTime? closedAt;
  const Shift({
    required this.id,
    required this.outletId,
    required this.userId,
    required this.shiftNumber,
    required this.openingCash,
    this.closingCash,
    this.expectedCash,
    this.totalSales,
    required this.status,
    required this.openedAt,
    this.closedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['outlet_id'] = Variable<String>(outletId);
    map['user_id'] = Variable<String>(userId);
    map['shift_number'] = Variable<int>(shiftNumber);
    map['opening_cash'] = Variable<double>(openingCash);
    if (!nullToAbsent || closingCash != null) {
      map['closing_cash'] = Variable<double>(closingCash);
    }
    if (!nullToAbsent || expectedCash != null) {
      map['expected_cash'] = Variable<double>(expectedCash);
    }
    if (!nullToAbsent || totalSales != null) {
      map['total_sales'] = Variable<double>(totalSales);
    }
    map['status'] = Variable<String>(status);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      outletId: Value(outletId),
      userId: Value(userId),
      shiftNumber: Value(shiftNumber),
      openingCash: Value(openingCash),
      closingCash: closingCash == null && nullToAbsent
          ? const Value.absent()
          : Value(closingCash),
      expectedCash: expectedCash == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCash),
      totalSales: totalSales == null && nullToAbsent
          ? const Value.absent()
          : Value(totalSales),
      status: Value(status),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
    );
  }

  factory Shift.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shift(
      id: serializer.fromJson<String>(json['id']),
      outletId: serializer.fromJson<String>(json['outletId']),
      userId: serializer.fromJson<String>(json['userId']),
      shiftNumber: serializer.fromJson<int>(json['shiftNumber']),
      openingCash: serializer.fromJson<double>(json['openingCash']),
      closingCash: serializer.fromJson<double?>(json['closingCash']),
      expectedCash: serializer.fromJson<double?>(json['expectedCash']),
      totalSales: serializer.fromJson<double?>(json['totalSales']),
      status: serializer.fromJson<String>(json['status']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'outletId': serializer.toJson<String>(outletId),
      'userId': serializer.toJson<String>(userId),
      'shiftNumber': serializer.toJson<int>(shiftNumber),
      'openingCash': serializer.toJson<double>(openingCash),
      'closingCash': serializer.toJson<double?>(closingCash),
      'expectedCash': serializer.toJson<double?>(expectedCash),
      'totalSales': serializer.toJson<double?>(totalSales),
      'status': serializer.toJson<String>(status),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
    };
  }

  Shift copyWith({
    String? id,
    String? outletId,
    String? userId,
    int? shiftNumber,
    double? openingCash,
    Value<double?> closingCash = const Value.absent(),
    Value<double?> expectedCash = const Value.absent(),
    Value<double?> totalSales = const Value.absent(),
    String? status,
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
  }) => Shift(
    id: id ?? this.id,
    outletId: outletId ?? this.outletId,
    userId: userId ?? this.userId,
    shiftNumber: shiftNumber ?? this.shiftNumber,
    openingCash: openingCash ?? this.openingCash,
    closingCash: closingCash.present ? closingCash.value : this.closingCash,
    expectedCash: expectedCash.present ? expectedCash.value : this.expectedCash,
    totalSales: totalSales.present ? totalSales.value : this.totalSales,
    status: status ?? this.status,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
  );
  Shift copyWithCompanion(ShiftsCompanion data) {
    return Shift(
      id: data.id.present ? data.id.value : this.id,
      outletId: data.outletId.present ? data.outletId.value : this.outletId,
      userId: data.userId.present ? data.userId.value : this.userId,
      shiftNumber: data.shiftNumber.present
          ? data.shiftNumber.value
          : this.shiftNumber,
      openingCash: data.openingCash.present
          ? data.openingCash.value
          : this.openingCash,
      closingCash: data.closingCash.present
          ? data.closingCash.value
          : this.closingCash,
      expectedCash: data.expectedCash.present
          ? data.expectedCash.value
          : this.expectedCash,
      totalSales: data.totalSales.present
          ? data.totalSales.value
          : this.totalSales,
      status: data.status.present ? data.status.value : this.status,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shift(')
          ..write('id: $id, ')
          ..write('outletId: $outletId, ')
          ..write('userId: $userId, ')
          ..write('shiftNumber: $shiftNumber, ')
          ..write('openingCash: $openingCash, ')
          ..write('closingCash: $closingCash, ')
          ..write('expectedCash: $expectedCash, ')
          ..write('totalSales: $totalSales, ')
          ..write('status: $status, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    outletId,
    userId,
    shiftNumber,
    openingCash,
    closingCash,
    expectedCash,
    totalSales,
    status,
    openedAt,
    closedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shift &&
          other.id == this.id &&
          other.outletId == this.outletId &&
          other.userId == this.userId &&
          other.shiftNumber == this.shiftNumber &&
          other.openingCash == this.openingCash &&
          other.closingCash == this.closingCash &&
          other.expectedCash == this.expectedCash &&
          other.totalSales == this.totalSales &&
          other.status == this.status &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt);
}

class ShiftsCompanion extends UpdateCompanion<Shift> {
  final Value<String> id;
  final Value<String> outletId;
  final Value<String> userId;
  final Value<int> shiftNumber;
  final Value<double> openingCash;
  final Value<double?> closingCash;
  final Value<double?> expectedCash;
  final Value<double?> totalSales;
  final Value<String> status;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.outletId = const Value.absent(),
    this.userId = const Value.absent(),
    this.shiftNumber = const Value.absent(),
    this.openingCash = const Value.absent(),
    this.closingCash = const Value.absent(),
    this.expectedCash = const Value.absent(),
    this.totalSales = const Value.absent(),
    this.status = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    required String outletId,
    required String userId,
    required int shiftNumber,
    required double openingCash,
    this.closingCash = const Value.absent(),
    this.expectedCash = const Value.absent(),
    this.totalSales = const Value.absent(),
    required String status,
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       outletId = Value(outletId),
       userId = Value(userId),
       shiftNumber = Value(shiftNumber),
       openingCash = Value(openingCash),
       status = Value(status);
  static Insertable<Shift> custom({
    Expression<String>? id,
    Expression<String>? outletId,
    Expression<String>? userId,
    Expression<int>? shiftNumber,
    Expression<double>? openingCash,
    Expression<double>? closingCash,
    Expression<double>? expectedCash,
    Expression<double>? totalSales,
    Expression<String>? status,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (outletId != null) 'outlet_id': outletId,
      if (userId != null) 'user_id': userId,
      if (shiftNumber != null) 'shift_number': shiftNumber,
      if (openingCash != null) 'opening_cash': openingCash,
      if (closingCash != null) 'closing_cash': closingCash,
      if (expectedCash != null) 'expected_cash': expectedCash,
      if (totalSales != null) 'total_sales': totalSales,
      if (status != null) 'status': status,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith({
    Value<String>? id,
    Value<String>? outletId,
    Value<String>? userId,
    Value<int>? shiftNumber,
    Value<double>? openingCash,
    Value<double?>? closingCash,
    Value<double?>? expectedCash,
    Value<double?>? totalSales,
    Value<String>? status,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<int>? rowid,
  }) {
    return ShiftsCompanion(
      id: id ?? this.id,
      outletId: outletId ?? this.outletId,
      userId: userId ?? this.userId,
      shiftNumber: shiftNumber ?? this.shiftNumber,
      openingCash: openingCash ?? this.openingCash,
      closingCash: closingCash ?? this.closingCash,
      expectedCash: expectedCash ?? this.expectedCash,
      totalSales: totalSales ?? this.totalSales,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (outletId.present) {
      map['outlet_id'] = Variable<String>(outletId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (shiftNumber.present) {
      map['shift_number'] = Variable<int>(shiftNumber.value);
    }
    if (openingCash.present) {
      map['opening_cash'] = Variable<double>(openingCash.value);
    }
    if (closingCash.present) {
      map['closing_cash'] = Variable<double>(closingCash.value);
    }
    if (expectedCash.present) {
      map['expected_cash'] = Variable<double>(expectedCash.value);
    }
    if (totalSales.present) {
      map['total_sales'] = Variable<double>(totalSales.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('outletId: $outletId, ')
          ..write('userId: $userId, ')
          ..write('shiftNumber: $shiftNumber, ')
          ..write('openingCash: $openingCash, ')
          ..write('closingCash: $closingCash, ')
          ..write('expectedCash: $expectedCash, ')
          ..write('totalSales: $totalSales, ')
          ..write('status: $status, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftCashLogsTable extends ShiftCashLogs
    with TableInfo<$ShiftCashLogsTable, ShiftCashLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftCashLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shifts (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shiftId,
    type,
    amount,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shift_cash_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftCashLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftCashLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftCashLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ShiftCashLogsTable createAlias(String alias) {
    return $ShiftCashLogsTable(attachedDatabase, alias);
  }
}

class ShiftCashLog extends DataClass implements Insertable<ShiftCashLog> {
  final String id;
  final String shiftId;
  final String type;
  final double amount;
  final String? note;
  final DateTime createdAt;
  const ShiftCashLog({
    required this.id,
    required this.shiftId,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shift_id'] = Variable<String>(shiftId);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShiftCashLogsCompanion toCompanion(bool nullToAbsent) {
    return ShiftCashLogsCompanion(
      id: Value(id),
      shiftId: Value(shiftId),
      type: Value(type),
      amount: Value(amount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory ShiftCashLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftCashLog(
      id: serializer.fromJson<String>(json['id']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shiftId': serializer.toJson<String>(shiftId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ShiftCashLog copyWith({
    String? id,
    String? shiftId,
    String? type,
    double? amount,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => ShiftCashLog(
    id: id ?? this.id,
    shiftId: shiftId ?? this.shiftId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  ShiftCashLog copyWithCompanion(ShiftCashLogsCompanion data) {
    return ShiftCashLog(
      id: data.id.present ? data.id.value : this.id,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftCashLog(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shiftId, type, amount, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftCashLog &&
          other.id == this.id &&
          other.shiftId == this.shiftId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class ShiftCashLogsCompanion extends UpdateCompanion<ShiftCashLog> {
  final Value<String> id;
  final Value<String> shiftId;
  final Value<String> type;
  final Value<double> amount;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ShiftCashLogsCompanion({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftCashLogsCompanion.insert({
    required String id,
    required String shiftId,
    required String type,
    required double amount,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shiftId = Value(shiftId),
       type = Value(type),
       amount = Value(amount);
  static Insertable<ShiftCashLog> custom({
    Expression<String>? id,
    Expression<String>? shiftId,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftId != null) 'shift_id': shiftId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftCashLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? shiftId,
    Value<String>? type,
    Value<double>? amount,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ShiftCashLogsCompanion(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftCashLogsCompanion(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outletIdMeta = const VerificationMeta(
    'outletId',
  );
  @override
  late final GeneratedColumn<String> outletId = GeneratedColumn<String>(
    'outlet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shifts (id)',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
    'tax_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _serviceChargeAmountMeta =
      const VerificationMeta('serviceChargeAmount');
  @override
  late final GeneratedColumn<double> serviceChargeAmount =
      GeneratedColumn<double>(
        'service_charge_amount',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOfflineMeta = const VerificationMeta(
    'isOffline',
  );
  @override
  late final GeneratedColumn<bool> isOffline = GeneratedColumn<bool>(
    'is_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _offlineIdMeta = const VerificationMeta(
    'offlineId',
  );
  @override
  late final GeneratedColumn<String> offlineId = GeneratedColumn<String>(
    'offline_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    outletId,
    shiftId,
    customerId,
    channel,
    subtotal,
    discountAmount,
    taxAmount,
    serviceChargeAmount,
    total,
    paymentStatus,
    status,
    isOffline,
    offlineId,
    dueDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('outlet_id')) {
      context.handle(
        _outletIdMeta,
        outletId.isAcceptableOrUnknown(data['outlet_id']!, _outletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outletIdMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    } else if (isInserting) {
      context.missing(_channelMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    }
    if (data.containsKey('service_charge_amount')) {
      context.handle(
        _serviceChargeAmountMeta,
        serviceChargeAmount.isAcceptableOrUnknown(
          data['service_charge_amount']!,
          _serviceChargeAmountMeta,
        ),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentStatusMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_offline')) {
      context.handle(
        _isOfflineMeta,
        isOffline.isAcceptableOrUnknown(data['is_offline']!, _isOfflineMeta),
      );
    }
    if (data.containsKey('offline_id')) {
      context.handle(
        _offlineIdMeta,
        offlineId.isAcceptableOrUnknown(data['offline_id']!, _offlineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_offlineIdMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      outletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outlet_id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      )!,
      serviceChargeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}service_charge_amount'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_offline'],
      )!,
      offlineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offline_id'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String outletId;
  final String? shiftId;
  final String? customerId;
  final String channel;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double serviceChargeAmount;
  final double total;
  final String paymentStatus;
  final String status;
  final bool isOffline;
  final String offlineId;
  final DateTime? dueDate;
  final DateTime createdAt;
  const Transaction({
    required this.id,
    required this.outletId,
    this.shiftId,
    this.customerId,
    required this.channel,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.serviceChargeAmount,
    required this.total,
    required this.paymentStatus,
    required this.status,
    required this.isOffline,
    required this.offlineId,
    this.dueDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['outlet_id'] = Variable<String>(outletId);
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['channel'] = Variable<String>(channel);
    map['subtotal'] = Variable<double>(subtotal);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['service_charge_amount'] = Variable<double>(serviceChargeAmount);
    map['total'] = Variable<double>(total);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['status'] = Variable<String>(status);
    map['is_offline'] = Variable<bool>(isOffline);
    map['offline_id'] = Variable<String>(offlineId);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      outletId: Value(outletId),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      channel: Value(channel),
      subtotal: Value(subtotal),
      discountAmount: Value(discountAmount),
      taxAmount: Value(taxAmount),
      serviceChargeAmount: Value(serviceChargeAmount),
      total: Value(total),
      paymentStatus: Value(paymentStatus),
      status: Value(status),
      isOffline: Value(isOffline),
      offlineId: Value(offlineId),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      createdAt: Value(createdAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      outletId: serializer.fromJson<String>(json['outletId']),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      channel: serializer.fromJson<String>(json['channel']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      serviceChargeAmount: serializer.fromJson<double>(
        json['serviceChargeAmount'],
      ),
      total: serializer.fromJson<double>(json['total']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      status: serializer.fromJson<String>(json['status']),
      isOffline: serializer.fromJson<bool>(json['isOffline']),
      offlineId: serializer.fromJson<String>(json['offlineId']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'outletId': serializer.toJson<String>(outletId),
      'shiftId': serializer.toJson<String?>(shiftId),
      'customerId': serializer.toJson<String?>(customerId),
      'channel': serializer.toJson<String>(channel),
      'subtotal': serializer.toJson<double>(subtotal),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'serviceChargeAmount': serializer.toJson<double>(serviceChargeAmount),
      'total': serializer.toJson<double>(total),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'status': serializer.toJson<String>(status),
      'isOffline': serializer.toJson<bool>(isOffline),
      'offlineId': serializer.toJson<String>(offlineId),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Transaction copyWith({
    String? id,
    String? outletId,
    Value<String?> shiftId = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? channel,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? serviceChargeAmount,
    double? total,
    String? paymentStatus,
    String? status,
    bool? isOffline,
    String? offlineId,
    Value<DateTime?> dueDate = const Value.absent(),
    DateTime? createdAt,
  }) => Transaction(
    id: id ?? this.id,
    outletId: outletId ?? this.outletId,
    shiftId: shiftId.present ? shiftId.value : this.shiftId,
    customerId: customerId.present ? customerId.value : this.customerId,
    channel: channel ?? this.channel,
    subtotal: subtotal ?? this.subtotal,
    discountAmount: discountAmount ?? this.discountAmount,
    taxAmount: taxAmount ?? this.taxAmount,
    serviceChargeAmount: serviceChargeAmount ?? this.serviceChargeAmount,
    total: total ?? this.total,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    status: status ?? this.status,
    isOffline: isOffline ?? this.isOffline,
    offlineId: offlineId ?? this.offlineId,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    createdAt: createdAt ?? this.createdAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      outletId: data.outletId.present ? data.outletId.value : this.outletId,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      channel: data.channel.present ? data.channel.value : this.channel,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      serviceChargeAmount: data.serviceChargeAmount.present
          ? data.serviceChargeAmount.value
          : this.serviceChargeAmount,
      total: data.total.present ? data.total.value : this.total,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      status: data.status.present ? data.status.value : this.status,
      isOffline: data.isOffline.present ? data.isOffline.value : this.isOffline,
      offlineId: data.offlineId.present ? data.offlineId.value : this.offlineId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('outletId: $outletId, ')
          ..write('shiftId: $shiftId, ')
          ..write('customerId: $customerId, ')
          ..write('channel: $channel, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('serviceChargeAmount: $serviceChargeAmount, ')
          ..write('total: $total, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('status: $status, ')
          ..write('isOffline: $isOffline, ')
          ..write('offlineId: $offlineId, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    outletId,
    shiftId,
    customerId,
    channel,
    subtotal,
    discountAmount,
    taxAmount,
    serviceChargeAmount,
    total,
    paymentStatus,
    status,
    isOffline,
    offlineId,
    dueDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.outletId == this.outletId &&
          other.shiftId == this.shiftId &&
          other.customerId == this.customerId &&
          other.channel == this.channel &&
          other.subtotal == this.subtotal &&
          other.discountAmount == this.discountAmount &&
          other.taxAmount == this.taxAmount &&
          other.serviceChargeAmount == this.serviceChargeAmount &&
          other.total == this.total &&
          other.paymentStatus == this.paymentStatus &&
          other.status == this.status &&
          other.isOffline == this.isOffline &&
          other.offlineId == this.offlineId &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> outletId;
  final Value<String?> shiftId;
  final Value<String?> customerId;
  final Value<String> channel;
  final Value<double> subtotal;
  final Value<double> discountAmount;
  final Value<double> taxAmount;
  final Value<double> serviceChargeAmount;
  final Value<double> total;
  final Value<String> paymentStatus;
  final Value<String> status;
  final Value<bool> isOffline;
  final Value<String> offlineId;
  final Value<DateTime?> dueDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.outletId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.channel = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.serviceChargeAmount = const Value.absent(),
    this.total = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.isOffline = const Value.absent(),
    this.offlineId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String outletId,
    this.shiftId = const Value.absent(),
    this.customerId = const Value.absent(),
    required String channel,
    required double subtotal,
    this.discountAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.serviceChargeAmount = const Value.absent(),
    required double total,
    required String paymentStatus,
    required String status,
    this.isOffline = const Value.absent(),
    required String offlineId,
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       outletId = Value(outletId),
       channel = Value(channel),
       subtotal = Value(subtotal),
       total = Value(total),
       paymentStatus = Value(paymentStatus),
       status = Value(status),
       offlineId = Value(offlineId);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? outletId,
    Expression<String>? shiftId,
    Expression<String>? customerId,
    Expression<String>? channel,
    Expression<double>? subtotal,
    Expression<double>? discountAmount,
    Expression<double>? taxAmount,
    Expression<double>? serviceChargeAmount,
    Expression<double>? total,
    Expression<String>? paymentStatus,
    Expression<String>? status,
    Expression<bool>? isOffline,
    Expression<String>? offlineId,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (outletId != null) 'outlet_id': outletId,
      if (shiftId != null) 'shift_id': shiftId,
      if (customerId != null) 'customer_id': customerId,
      if (channel != null) 'channel': channel,
      if (subtotal != null) 'subtotal': subtotal,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (serviceChargeAmount != null)
        'service_charge_amount': serviceChargeAmount,
      if (total != null) 'total': total,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (status != null) 'status': status,
      if (isOffline != null) 'is_offline': isOffline,
      if (offlineId != null) 'offline_id': offlineId,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? outletId,
    Value<String?>? shiftId,
    Value<String?>? customerId,
    Value<String>? channel,
    Value<double>? subtotal,
    Value<double>? discountAmount,
    Value<double>? taxAmount,
    Value<double>? serviceChargeAmount,
    Value<double>? total,
    Value<String>? paymentStatus,
    Value<String>? status,
    Value<bool>? isOffline,
    Value<String>? offlineId,
    Value<DateTime?>? dueDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      outletId: outletId ?? this.outletId,
      shiftId: shiftId ?? this.shiftId,
      customerId: customerId ?? this.customerId,
      channel: channel ?? this.channel,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceChargeAmount: serviceChargeAmount ?? this.serviceChargeAmount,
      total: total ?? this.total,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      isOffline: isOffline ?? this.isOffline,
      offlineId: offlineId ?? this.offlineId,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (outletId.present) {
      map['outlet_id'] = Variable<String>(outletId.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (serviceChargeAmount.present) {
      map['service_charge_amount'] = Variable<double>(
        serviceChargeAmount.value,
      );
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isOffline.present) {
      map['is_offline'] = Variable<bool>(isOffline.value);
    }
    if (offlineId.present) {
      map['offline_id'] = Variable<String>(offlineId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('outletId: $outletId, ')
          ..write('shiftId: $shiftId, ')
          ..write('customerId: $customerId, ')
          ..write('channel: $channel, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('serviceChargeAmount: $serviceChargeAmount, ')
          ..write('total: $total, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('status: $status, ')
          ..write('isOffline: $isOffline, ')
          ..write('offlineId: $offlineId, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionItemsTable extends TransactionItems
    with TableInfo<$TransactionItemsTable, TransactionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    productId,
    productName,
    price,
    qty,
    discountAmount,
    subtotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qty'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
    );
  }

  @override
  $TransactionItemsTable createAlias(String alias) {
    return $TransactionItemsTable(attachedDatabase, alias);
  }
}

class TransactionItem extends DataClass implements Insertable<TransactionItem> {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final double price;
  final double qty;
  final double discountAmount;
  final double subtotal;
  const TransactionItem({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
    required this.discountAmount,
    required this.subtotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['price'] = Variable<double>(price);
    map['qty'] = Variable<double>(qty);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['subtotal'] = Variable<double>(subtotal);
    return map;
  }

  TransactionItemsCompanion toCompanion(bool nullToAbsent) {
    return TransactionItemsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      productId: Value(productId),
      productName: Value(productName),
      price: Value(price),
      qty: Value(qty),
      discountAmount: Value(discountAmount),
      subtotal: Value(subtotal),
    );
  }

  factory TransactionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionItem(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      price: serializer.fromJson<double>(json['price']),
      qty: serializer.fromJson<double>(json['qty']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'price': serializer.toJson<double>(price),
      'qty': serializer.toJson<double>(qty),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'subtotal': serializer.toJson<double>(subtotal),
    };
  }

  TransactionItem copyWith({
    String? id,
    String? transactionId,
    String? productId,
    String? productName,
    double? price,
    double? qty,
    double? discountAmount,
    double? subtotal,
  }) => TransactionItem(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    price: price ?? this.price,
    qty: qty ?? this.qty,
    discountAmount: discountAmount ?? this.discountAmount,
    subtotal: subtotal ?? this.subtotal,
  );
  TransactionItem copyWithCompanion(TransactionItemsCompanion data) {
    return TransactionItem(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      price: data.price.present ? data.price.value : this.price,
      qty: data.qty.present ? data.qty.value : this.qty,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItem(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    productId,
    productName,
    price,
    qty,
    discountAmount,
    subtotal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItem &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.price == this.price &&
          other.qty == this.qty &&
          other.discountAmount == this.discountAmount &&
          other.subtotal == this.subtotal);
}

class TransactionItemsCompanion extends UpdateCompanion<TransactionItem> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<double> price;
  final Value<double> qty;
  final Value<double> discountAmount;
  final Value<double> subtotal;
  final Value<int> rowid;
  const TransactionItemsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.price = const Value.absent(),
    this.qty = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionItemsCompanion.insert({
    required String id,
    required String transactionId,
    required String productId,
    required String productName,
    required double price,
    required double qty,
    this.discountAmount = const Value.absent(),
    required double subtotal,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       productId = Value(productId),
       productName = Value(productName),
       price = Value(price),
       qty = Value(qty),
       subtotal = Value(subtotal);
  static Insertable<TransactionItem> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<double>? price,
    Expression<double>? qty,
    Expression<double>? discountAmount,
    Expression<double>? subtotal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (price != null) 'price': price,
      if (qty != null) 'qty': qty,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (subtotal != null) 'subtotal': subtotal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? productId,
    Value<String>? productName,
    Value<double>? price,
    Value<double>? qty,
    Value<double>? discountAmount,
    Value<double>? subtotal,
    Value<int>? rowid,
  }) {
    return TransactionItemsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      discountAmount: discountAmount ?? this.discountAmount,
      subtotal: subtotal ?? this.subtotal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('subtotal: $subtotal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionItemModifiersTable extends TransactionItemModifiers
    with TableInfo<$TransactionItemModifiersTable, TransactionItemModifier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionItemModifiersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionItemIdMeta = const VerificationMeta(
    'transactionItemId',
  );
  @override
  late final GeneratedColumn<String> transactionItemId =
      GeneratedColumn<String>(
        'transaction_item_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transaction_items (id)',
        ),
      );
  static const VerificationMeta _modifierNameMeta = const VerificationMeta(
    'modifierName',
  );
  @override
  late final GeneratedColumn<String> modifierName = GeneratedColumn<String>(
    'modifier_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceAdjustmentMeta = const VerificationMeta(
    'priceAdjustment',
  );
  @override
  late final GeneratedColumn<double> priceAdjustment = GeneratedColumn<double>(
    'price_adjustment',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionItemId,
    modifierName,
    priceAdjustment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_item_modifiers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionItemModifier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_item_id')) {
      context.handle(
        _transactionItemIdMeta,
        transactionItemId.isAcceptableOrUnknown(
          data['transaction_item_id']!,
          _transactionItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionItemIdMeta);
    }
    if (data.containsKey('modifier_name')) {
      context.handle(
        _modifierNameMeta,
        modifierName.isAcceptableOrUnknown(
          data['modifier_name']!,
          _modifierNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modifierNameMeta);
    }
    if (data.containsKey('price_adjustment')) {
      context.handle(
        _priceAdjustmentMeta,
        priceAdjustment.isAcceptableOrUnknown(
          data['price_adjustment']!,
          _priceAdjustmentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_priceAdjustmentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionItemModifier map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionItemModifier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_item_id'],
      )!,
      modifierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modifier_name'],
      )!,
      priceAdjustment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_adjustment'],
      )!,
    );
  }

  @override
  $TransactionItemModifiersTable createAlias(String alias) {
    return $TransactionItemModifiersTable(attachedDatabase, alias);
  }
}

class TransactionItemModifier extends DataClass
    implements Insertable<TransactionItemModifier> {
  final String id;
  final String transactionItemId;
  final String modifierName;
  final double priceAdjustment;
  const TransactionItemModifier({
    required this.id,
    required this.transactionItemId,
    required this.modifierName,
    required this.priceAdjustment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_item_id'] = Variable<String>(transactionItemId);
    map['modifier_name'] = Variable<String>(modifierName);
    map['price_adjustment'] = Variable<double>(priceAdjustment);
    return map;
  }

  TransactionItemModifiersCompanion toCompanion(bool nullToAbsent) {
    return TransactionItemModifiersCompanion(
      id: Value(id),
      transactionItemId: Value(transactionItemId),
      modifierName: Value(modifierName),
      priceAdjustment: Value(priceAdjustment),
    );
  }

  factory TransactionItemModifier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionItemModifier(
      id: serializer.fromJson<String>(json['id']),
      transactionItemId: serializer.fromJson<String>(json['transactionItemId']),
      modifierName: serializer.fromJson<String>(json['modifierName']),
      priceAdjustment: serializer.fromJson<double>(json['priceAdjustment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionItemId': serializer.toJson<String>(transactionItemId),
      'modifierName': serializer.toJson<String>(modifierName),
      'priceAdjustment': serializer.toJson<double>(priceAdjustment),
    };
  }

  TransactionItemModifier copyWith({
    String? id,
    String? transactionItemId,
    String? modifierName,
    double? priceAdjustment,
  }) => TransactionItemModifier(
    id: id ?? this.id,
    transactionItemId: transactionItemId ?? this.transactionItemId,
    modifierName: modifierName ?? this.modifierName,
    priceAdjustment: priceAdjustment ?? this.priceAdjustment,
  );
  TransactionItemModifier copyWithCompanion(
    TransactionItemModifiersCompanion data,
  ) {
    return TransactionItemModifier(
      id: data.id.present ? data.id.value : this.id,
      transactionItemId: data.transactionItemId.present
          ? data.transactionItemId.value
          : this.transactionItemId,
      modifierName: data.modifierName.present
          ? data.modifierName.value
          : this.modifierName,
      priceAdjustment: data.priceAdjustment.present
          ? data.priceAdjustment.value
          : this.priceAdjustment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemModifier(')
          ..write('id: $id, ')
          ..write('transactionItemId: $transactionItemId, ')
          ..write('modifierName: $modifierName, ')
          ..write('priceAdjustment: $priceAdjustment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, transactionItemId, modifierName, priceAdjustment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItemModifier &&
          other.id == this.id &&
          other.transactionItemId == this.transactionItemId &&
          other.modifierName == this.modifierName &&
          other.priceAdjustment == this.priceAdjustment);
}

class TransactionItemModifiersCompanion
    extends UpdateCompanion<TransactionItemModifier> {
  final Value<String> id;
  final Value<String> transactionItemId;
  final Value<String> modifierName;
  final Value<double> priceAdjustment;
  final Value<int> rowid;
  const TransactionItemModifiersCompanion({
    this.id = const Value.absent(),
    this.transactionItemId = const Value.absent(),
    this.modifierName = const Value.absent(),
    this.priceAdjustment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionItemModifiersCompanion.insert({
    required String id,
    required String transactionItemId,
    required String modifierName,
    required double priceAdjustment,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionItemId = Value(transactionItemId),
       modifierName = Value(modifierName),
       priceAdjustment = Value(priceAdjustment);
  static Insertable<TransactionItemModifier> custom({
    Expression<String>? id,
    Expression<String>? transactionItemId,
    Expression<String>? modifierName,
    Expression<double>? priceAdjustment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionItemId != null) 'transaction_item_id': transactionItemId,
      if (modifierName != null) 'modifier_name': modifierName,
      if (priceAdjustment != null) 'price_adjustment': priceAdjustment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionItemModifiersCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionItemId,
    Value<String>? modifierName,
    Value<double>? priceAdjustment,
    Value<int>? rowid,
  }) {
    return TransactionItemModifiersCompanion(
      id: id ?? this.id,
      transactionItemId: transactionItemId ?? this.transactionItemId,
      modifierName: modifierName ?? this.modifierName,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionItemId.present) {
      map['transaction_item_id'] = Variable<String>(transactionItemId.value);
    }
    if (modifierName.present) {
      map['modifier_name'] = Variable<String>(modifierName.value);
    }
    if (priceAdjustment.present) {
      map['price_adjustment'] = Variable<double>(priceAdjustment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemModifiersCompanion(')
          ..write('id: $id, ')
          ..write('transactionItemId: $transactionItemId, ')
          ..write('modifierName: $modifierName, ')
          ..write('priceAdjustment: $priceAdjustment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionPaymentsTable extends TransactionPayments
    with TableInfo<$TransactionPaymentsTable, TransactionPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _paymentMethodIdMeta = const VerificationMeta(
    'paymentMethodId',
  );
  @override
  late final GeneratedColumn<String> paymentMethodId = GeneratedColumn<String>(
    'payment_method_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payment_methods (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeAmountMeta = const VerificationMeta(
    'changeAmount',
  );
  @override
  late final GeneratedColumn<double> changeAmount = GeneratedColumn<double>(
    'change_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    paymentMethodId,
    amount,
    changeAmount,
    paidAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('payment_method_id')) {
      context.handle(
        _paymentMethodIdMeta,
        paymentMethodId.isAcceptableOrUnknown(
          data['payment_method_id']!,
          _paymentMethodIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('change_amount')) {
      context.handle(
        _changeAmountMeta,
        changeAmount.isAcceptableOrUnknown(
          data['change_amount']!,
          _changeAmountMeta,
        ),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      paymentMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      changeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}change_amount'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      )!,
    );
  }

  @override
  $TransactionPaymentsTable createAlias(String alias) {
    return $TransactionPaymentsTable(attachedDatabase, alias);
  }
}

class TransactionPayment extends DataClass
    implements Insertable<TransactionPayment> {
  final String id;
  final String transactionId;
  final String paymentMethodId;
  final double amount;
  final double changeAmount;
  final DateTime paidAt;
  const TransactionPayment({
    required this.id,
    required this.transactionId,
    required this.paymentMethodId,
    required this.amount,
    required this.changeAmount,
    required this.paidAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['payment_method_id'] = Variable<String>(paymentMethodId);
    map['amount'] = Variable<double>(amount);
    map['change_amount'] = Variable<double>(changeAmount);
    map['paid_at'] = Variable<DateTime>(paidAt);
    return map;
  }

  TransactionPaymentsCompanion toCompanion(bool nullToAbsent) {
    return TransactionPaymentsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      paymentMethodId: Value(paymentMethodId),
      amount: Value(amount),
      changeAmount: Value(changeAmount),
      paidAt: Value(paidAt),
    );
  }

  factory TransactionPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionPayment(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      paymentMethodId: serializer.fromJson<String>(json['paymentMethodId']),
      amount: serializer.fromJson<double>(json['amount']),
      changeAmount: serializer.fromJson<double>(json['changeAmount']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'paymentMethodId': serializer.toJson<String>(paymentMethodId),
      'amount': serializer.toJson<double>(amount),
      'changeAmount': serializer.toJson<double>(changeAmount),
      'paidAt': serializer.toJson<DateTime>(paidAt),
    };
  }

  TransactionPayment copyWith({
    String? id,
    String? transactionId,
    String? paymentMethodId,
    double? amount,
    double? changeAmount,
    DateTime? paidAt,
  }) => TransactionPayment(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    paymentMethodId: paymentMethodId ?? this.paymentMethodId,
    amount: amount ?? this.amount,
    changeAmount: changeAmount ?? this.changeAmount,
    paidAt: paidAt ?? this.paidAt,
  );
  TransactionPayment copyWithCompanion(TransactionPaymentsCompanion data) {
    return TransactionPayment(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      paymentMethodId: data.paymentMethodId.present
          ? data.paymentMethodId.value
          : this.paymentMethodId,
      amount: data.amount.present ? data.amount.value : this.amount,
      changeAmount: data.changeAmount.present
          ? data.changeAmount.value
          : this.changeAmount,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionPayment(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('amount: $amount, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('paidAt: $paidAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    paymentMethodId,
    amount,
    changeAmount,
    paidAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionPayment &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.paymentMethodId == this.paymentMethodId &&
          other.amount == this.amount &&
          other.changeAmount == this.changeAmount &&
          other.paidAt == this.paidAt);
}

class TransactionPaymentsCompanion extends UpdateCompanion<TransactionPayment> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> paymentMethodId;
  final Value<double> amount;
  final Value<double> changeAmount;
  final Value<DateTime> paidAt;
  final Value<int> rowid;
  const TransactionPaymentsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.amount = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionPaymentsCompanion.insert({
    required String id,
    required String transactionId,
    required String paymentMethodId,
    required double amount,
    this.changeAmount = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       paymentMethodId = Value(paymentMethodId),
       amount = Value(amount);
  static Insertable<TransactionPayment> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? paymentMethodId,
    Expression<double>? amount,
    Expression<double>? changeAmount,
    Expression<DateTime>? paidAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (amount != null) 'amount': amount,
      if (changeAmount != null) 'change_amount': changeAmount,
      if (paidAt != null) 'paid_at': paidAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? paymentMethodId,
    Value<double>? amount,
    Value<double>? changeAmount,
    Value<DateTime>? paidAt,
    Value<int>? rowid,
  }) {
    return TransactionPaymentsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      amount: amount ?? this.amount,
      changeAmount: changeAmount ?? this.changeAmount,
      paidAt: paidAt ?? this.paidAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (paymentMethodId.present) {
      map['payment_method_id'] = Variable<String>(paymentMethodId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (changeAmount.present) {
      map['change_amount'] = Variable<double>(changeAmount.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('amount: $amount, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('paidAt: $paidAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmployeesTable extends Employees
    with TableInfo<$EmployeesTable, Employee> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinMeta = const VerificationMeta('pin');
  @override
  late final GeneratedColumn<String> pin = GeneratedColumn<String>(
    'pin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<String> photo = GeneratedColumn<String>(
    'photo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, email, pin, photo, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employees';
  @override
  VerificationContext validateIntegrity(
    Insertable<Employee> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('pin')) {
      context.handle(
        _pinMeta,
        pin.isAcceptableOrUnknown(data['pin']!, _pinMeta),
      );
    }
    if (data.containsKey('photo')) {
      context.handle(
        _photoMeta,
        photo.isAcceptableOrUnknown(data['photo']!, _photoMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Employee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Employee(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      pin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin'],
      ),
      photo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
    );
  }

  @override
  $EmployeesTable createAlias(String alias) {
    return $EmployeesTable(attachedDatabase, alias);
  }
}

class Employee extends DataClass implements Insertable<Employee> {
  final String id;
  final String name;
  final String? email;
  final String? pin;
  final String? photo;
  final String? role;
  const Employee({
    required this.id,
    required this.name,
    this.email,
    this.pin,
    this.photo,
    this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || pin != null) {
      map['pin'] = Variable<String>(pin);
    }
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<String>(photo);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      id: Value(id),
      name: Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      pin: pin == null && nullToAbsent ? const Value.absent() : Value(pin),
      photo: photo == null && nullToAbsent
          ? const Value.absent()
          : Value(photo),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
    );
  }

  factory Employee.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Employee(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      pin: serializer.fromJson<String?>(json['pin']),
      photo: serializer.fromJson<String?>(json['photo']),
      role: serializer.fromJson<String?>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'pin': serializer.toJson<String?>(pin),
      'photo': serializer.toJson<String?>(photo),
      'role': serializer.toJson<String?>(role),
    };
  }

  Employee copyWith({
    String? id,
    String? name,
    Value<String?> email = const Value.absent(),
    Value<String?> pin = const Value.absent(),
    Value<String?> photo = const Value.absent(),
    Value<String?> role = const Value.absent(),
  }) => Employee(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email.present ? email.value : this.email,
    pin: pin.present ? pin.value : this.pin,
    photo: photo.present ? photo.value : this.photo,
    role: role.present ? role.value : this.role,
  );
  Employee copyWithCompanion(EmployeesCompanion data) {
    return Employee(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      pin: data.pin.present ? data.pin.value : this.pin,
      photo: data.photo.present ? data.photo.value : this.photo,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Employee(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('pin: $pin, ')
          ..write('photo: $photo, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, pin, photo, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Employee &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.pin == this.pin &&
          other.photo == this.photo &&
          other.role == this.role);
}

class EmployeesCompanion extends UpdateCompanion<Employee> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String?> pin;
  final Value<String?> photo;
  final Value<String?> role;
  final Value<int> rowid;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.pin = const Value.absent(),
    this.photo = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmployeesCompanion.insert({
    required String id,
    required String name,
    this.email = const Value.absent(),
    this.pin = const Value.absent(),
    this.photo = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Employee> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? pin,
    Expression<String>? photo,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (pin != null) 'pin': pin,
      if (photo != null) 'photo': photo,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmployeesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? email,
    Value<String?>? pin,
    Value<String?>? photo,
    Value<String?>? role,
    Value<int>? rowid,
  }) {
    return EmployeesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      pin: pin ?? this.pin,
      photo: photo ?? this.photo,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (pin.present) {
      map['pin'] = Variable<String>(pin.value);
    }
    if (photo.present) {
      map['photo'] = Variable<String>(photo.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('pin: $pin, ')
          ..write('photo: $photo, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $VariantsTable variants = $VariantsTable(this);
  late final $InventoriesTable inventories = $InventoriesTable(this);
  late final $PaymentMethodsTable paymentMethods = $PaymentMethodsTable(this);
  late final $OutletSettingsTable outletSettings = $OutletSettingsTable(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $ShiftCashLogsTable shiftCashLogs = $ShiftCashLogsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionItemsTable transactionItems = $TransactionItemsTable(
    this,
  );
  late final $TransactionItemModifiersTable transactionItemModifiers =
      $TransactionItemModifiersTable(this);
  late final $TransactionPaymentsTable transactionPayments =
      $TransactionPaymentsTable(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    products,
    variants,
    inventories,
    paymentMethods,
    outletSettings,
    shifts,
    shiftCashLogs,
    transactions,
    transactionItems,
    transactionItemModifiers,
    transactionPayments,
    employees,
  ];
}

typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String name,
      Value<String?> categoryId,
      Value<String?> sku,
      Value<String?> barcode,
      required double price,
      Value<bool> isAvailable,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> categoryId,
      Value<String?> sku,
      Value<String?> barcode,
      Value<double> price,
      Value<bool> isAvailable,
      Value<int> rowid,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VariantsTable, List<Variant>> _variantsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.variants,
    aliasName: 'products__id__variants__product_id',
  );

  $$VariantsTableProcessedTableManager get variantsRefs {
    final manager = $$VariantsTableTableManager(
      $_db,
      $_db.variants,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_variantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InventoriesTable, List<Inventory>>
  _inventoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.inventories,
    aliasName: 'products__id__inventories__product_id',
  );

  $$InventoriesTableProcessedTableManager get inventoriesRefs {
    final manager = $$InventoriesTableTableManager(
      $_db,
      $_db.inventories,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_inventoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> variantsRefs(
    Expression<bool> Function($$VariantsTableFilterComposer f) f,
  ) {
    final $$VariantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.variants,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VariantsTableFilterComposer(
            $db: $db,
            $table: $db.variants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inventoriesRefs(
    Expression<bool> Function($$InventoriesTableFilterComposer f) f,
  ) {
    final $$InventoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventories,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoriesTableFilterComposer(
            $db: $db,
            $table: $db.inventories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => column,
  );

  Expression<T> variantsRefs<T extends Object>(
    Expression<T> Function($$VariantsTableAnnotationComposer a) f,
  ) {
    final $$VariantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.variants,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VariantsTableAnnotationComposer(
            $db: $db,
            $table: $db.variants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> inventoriesRefs<T extends Object>(
    Expression<T> Function($$InventoriesTableAnnotationComposer a) f,
  ) {
    final $$InventoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventories,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.inventories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, $$ProductsTableReferences),
          Product,
          PrefetchHooks Function({bool variantsRefs, bool inventoriesRefs})
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<bool> isAvailable = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                categoryId: categoryId,
                sku: sku,
                barcode: barcode,
                price: price,
                isAvailable: isAvailable,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required double price,
                Value<bool> isAvailable = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                categoryId: categoryId,
                sku: sku,
                barcode: barcode,
                price: price,
                isAvailable: isAvailable,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({variantsRefs = false, inventoriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (variantsRefs) db.variants,
                    if (inventoriesRefs) db.inventories,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (variantsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          Variant
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._variantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).variantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (inventoriesRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          Inventory
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._inventoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, $$ProductsTableReferences),
      Product,
      PrefetchHooks Function({bool variantsRefs, bool inventoriesRefs})
    >;
typedef $$VariantsTableCreateCompanionBuilder =
    VariantsCompanion Function({
      required String id,
      required String productId,
      required String name,
      Value<double> priceAdjustment,
      Value<int> rowid,
    });
typedef $$VariantsTableUpdateCompanionBuilder =
    VariantsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> name,
      Value<double> priceAdjustment,
      Value<int> rowid,
    });

final class $$VariantsTableReferences
    extends BaseReferences<_$AppDatabase, $VariantsTable, Variant> {
  $$VariantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('variants__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VariantsTableFilterComposer
    extends Composer<_$AppDatabase, $VariantsTable> {
  $$VariantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priceAdjustment => $composableBuilder(
    column: $table.priceAdjustment,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VariantsTableOrderingComposer
    extends Composer<_$AppDatabase, $VariantsTable> {
  $$VariantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priceAdjustment => $composableBuilder(
    column: $table.priceAdjustment,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VariantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VariantsTable> {
  $$VariantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get priceAdjustment => $composableBuilder(
    column: $table.priceAdjustment,
    builder: (column) => column,
  );

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VariantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VariantsTable,
          Variant,
          $$VariantsTableFilterComposer,
          $$VariantsTableOrderingComposer,
          $$VariantsTableAnnotationComposer,
          $$VariantsTableCreateCompanionBuilder,
          $$VariantsTableUpdateCompanionBuilder,
          (Variant, $$VariantsTableReferences),
          Variant,
          PrefetchHooks Function({bool productId})
        > {
  $$VariantsTableTableManager(_$AppDatabase db, $VariantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VariantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VariantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VariantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> priceAdjustment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VariantsCompanion(
                id: id,
                productId: productId,
                name: name,
                priceAdjustment: priceAdjustment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String name,
                Value<double> priceAdjustment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VariantsCompanion.insert(
                id: id,
                productId: productId,
                name: name,
                priceAdjustment: priceAdjustment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VariantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$VariantsTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$VariantsTableReferences
                                    ._productIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VariantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VariantsTable,
      Variant,
      $$VariantsTableFilterComposer,
      $$VariantsTableOrderingComposer,
      $$VariantsTableAnnotationComposer,
      $$VariantsTableCreateCompanionBuilder,
      $$VariantsTableUpdateCompanionBuilder,
      (Variant, $$VariantsTableReferences),
      Variant,
      PrefetchHooks Function({bool productId})
    >;
typedef $$InventoriesTableCreateCompanionBuilder =
    InventoriesCompanion Function({
      required String productId,
      Value<double> stock,
      Value<int> rowid,
    });
typedef $$InventoriesTableUpdateCompanionBuilder =
    InventoriesCompanion Function({
      Value<String> productId,
      Value<double> stock,
      Value<int> rowid,
    });

final class $$InventoriesTableReferences
    extends BaseReferences<_$AppDatabase, $InventoriesTable, Inventory> {
  $$InventoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('inventories__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InventoriesTableFilterComposer
    extends Composer<_$AppDatabase, $InventoriesTable> {
  $$InventoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoriesTable> {
  $$InventoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoriesTable> {
  $$InventoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoriesTable,
          Inventory,
          $$InventoriesTableFilterComposer,
          $$InventoriesTableOrderingComposer,
          $$InventoriesTableAnnotationComposer,
          $$InventoriesTableCreateCompanionBuilder,
          $$InventoriesTableUpdateCompanionBuilder,
          (Inventory, $$InventoriesTableReferences),
          Inventory,
          PrefetchHooks Function({bool productId})
        > {
  $$InventoriesTableTableManager(_$AppDatabase db, $InventoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> productId = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoriesCompanion(
                productId: productId,
                stock: stock,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productId,
                Value<double> stock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoriesCompanion.insert(
                productId: productId,
                stock: stock,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InventoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$InventoriesTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$InventoriesTableReferences
                                    ._productIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InventoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoriesTable,
      Inventory,
      $$InventoriesTableFilterComposer,
      $$InventoriesTableOrderingComposer,
      $$InventoriesTableAnnotationComposer,
      $$InventoriesTableCreateCompanionBuilder,
      $$InventoriesTableUpdateCompanionBuilder,
      (Inventory, $$InventoriesTableReferences),
      Inventory,
      PrefetchHooks Function({bool productId})
    >;
typedef $$PaymentMethodsTableCreateCompanionBuilder =
    PaymentMethodsCompanion Function({
      required String id,
      required String name,
      required String type,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$PaymentMethodsTableUpdateCompanionBuilder =
    PaymentMethodsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<bool> isActive,
      Value<int> rowid,
    });

final class $$PaymentMethodsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentMethodsTable, PaymentMethod> {
  $$PaymentMethodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $TransactionPaymentsTable,
    List<TransactionPayment>
  >
  _transactionPaymentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionPayments,
        aliasName:
            'payment_methods__id__transaction_payments__payment_method_id',
      );

  $$TransactionPaymentsTableProcessedTableManager get transactionPaymentsRefs {
    final manager =
        $$TransactionPaymentsTableTableManager(
          $_db,
          $_db.transactionPayments,
        ).filter(
          (f) => f.paymentMethodId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _transactionPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaymentMethodsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionPaymentsRefs(
    Expression<bool> Function($$TransactionPaymentsTableFilterComposer f) f,
  ) {
    final $$TransactionPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionPayments,
      getReferencedColumn: (t) => t.paymentMethodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.transactionPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentMethodsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentMethodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> transactionPaymentsRefs<T extends Object>(
    Expression<T> Function($$TransactionPaymentsTableAnnotationComposer a) f,
  ) {
    final $$TransactionPaymentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionPayments,
          getReferencedColumn: (t) => t.paymentMethodId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionPaymentsTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionPayments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PaymentMethodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentMethodsTable,
          PaymentMethod,
          $$PaymentMethodsTableFilterComposer,
          $$PaymentMethodsTableOrderingComposer,
          $$PaymentMethodsTableAnnotationComposer,
          $$PaymentMethodsTableCreateCompanionBuilder,
          $$PaymentMethodsTableUpdateCompanionBuilder,
          (PaymentMethod, $$PaymentMethodsTableReferences),
          PaymentMethod,
          PrefetchHooks Function({bool transactionPaymentsRefs})
        > {
  $$PaymentMethodsTableTableManager(
    _$AppDatabase db,
    $PaymentMethodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentMethodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentMethodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentMethodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentMethodsCompanion(
                id: id,
                name: name,
                type: type,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentMethodsCompanion.insert(
                id: id,
                name: name,
                type: type,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentMethodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionPaymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionPaymentsRefs) db.transactionPayments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionPaymentsRefs)
                    await $_getPrefetchedData<
                      PaymentMethod,
                      $PaymentMethodsTable,
                      TransactionPayment
                    >(
                      currentTable: table,
                      referencedTable: $$PaymentMethodsTableReferences
                          ._transactionPaymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PaymentMethodsTableReferences(
                            db,
                            table,
                            p0,
                          ).transactionPaymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.paymentMethodId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PaymentMethodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentMethodsTable,
      PaymentMethod,
      $$PaymentMethodsTableFilterComposer,
      $$PaymentMethodsTableOrderingComposer,
      $$PaymentMethodsTableAnnotationComposer,
      $$PaymentMethodsTableCreateCompanionBuilder,
      $$PaymentMethodsTableUpdateCompanionBuilder,
      (PaymentMethod, $$PaymentMethodsTableReferences),
      PaymentMethod,
      PrefetchHooks Function({bool transactionPaymentsRefs})
    >;
typedef $$OutletSettingsTableCreateCompanionBuilder =
    OutletSettingsCompanion Function({
      required String id,
      Value<double> taxPercentage,
      Value<double> serviceChargePercentage,
      Value<String?> printerMacAddress,
      Value<int> rowid,
    });
typedef $$OutletSettingsTableUpdateCompanionBuilder =
    OutletSettingsCompanion Function({
      Value<String> id,
      Value<double> taxPercentage,
      Value<double> serviceChargePercentage,
      Value<String?> printerMacAddress,
      Value<int> rowid,
    });

class $$OutletSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $OutletSettingsTable> {
  $$OutletSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxPercentage => $composableBuilder(
    column: $table.taxPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get serviceChargePercentage => $composableBuilder(
    column: $table.serviceChargePercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printerMacAddress => $composableBuilder(
    column: $table.printerMacAddress,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutletSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutletSettingsTable> {
  $$OutletSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxPercentage => $composableBuilder(
    column: $table.taxPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get serviceChargePercentage => $composableBuilder(
    column: $table.serviceChargePercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printerMacAddress => $composableBuilder(
    column: $table.printerMacAddress,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutletSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutletSettingsTable> {
  $$OutletSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get taxPercentage => $composableBuilder(
    column: $table.taxPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get serviceChargePercentage => $composableBuilder(
    column: $table.serviceChargePercentage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get printerMacAddress => $composableBuilder(
    column: $table.printerMacAddress,
    builder: (column) => column,
  );
}

class $$OutletSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutletSettingsTable,
          OutletSetting,
          $$OutletSettingsTableFilterComposer,
          $$OutletSettingsTableOrderingComposer,
          $$OutletSettingsTableAnnotationComposer,
          $$OutletSettingsTableCreateCompanionBuilder,
          $$OutletSettingsTableUpdateCompanionBuilder,
          (
            OutletSetting,
            BaseReferences<_$AppDatabase, $OutletSettingsTable, OutletSetting>,
          ),
          OutletSetting,
          PrefetchHooks Function()
        > {
  $$OutletSettingsTableTableManager(
    _$AppDatabase db,
    $OutletSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutletSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutletSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutletSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> taxPercentage = const Value.absent(),
                Value<double> serviceChargePercentage = const Value.absent(),
                Value<String?> printerMacAddress = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutletSettingsCompanion(
                id: id,
                taxPercentage: taxPercentage,
                serviceChargePercentage: serviceChargePercentage,
                printerMacAddress: printerMacAddress,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<double> taxPercentage = const Value.absent(),
                Value<double> serviceChargePercentage = const Value.absent(),
                Value<String?> printerMacAddress = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutletSettingsCompanion.insert(
                id: id,
                taxPercentage: taxPercentage,
                serviceChargePercentage: serviceChargePercentage,
                printerMacAddress: printerMacAddress,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutletSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutletSettingsTable,
      OutletSetting,
      $$OutletSettingsTableFilterComposer,
      $$OutletSettingsTableOrderingComposer,
      $$OutletSettingsTableAnnotationComposer,
      $$OutletSettingsTableCreateCompanionBuilder,
      $$OutletSettingsTableUpdateCompanionBuilder,
      (
        OutletSetting,
        BaseReferences<_$AppDatabase, $OutletSettingsTable, OutletSetting>,
      ),
      OutletSetting,
      PrefetchHooks Function()
    >;
typedef $$ShiftsTableCreateCompanionBuilder =
    ShiftsCompanion Function({
      required String id,
      required String outletId,
      required String userId,
      required int shiftNumber,
      required double openingCash,
      Value<double?> closingCash,
      Value<double?> expectedCash,
      Value<double?> totalSales,
      required String status,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<int> rowid,
    });
typedef $$ShiftsTableUpdateCompanionBuilder =
    ShiftsCompanion Function({
      Value<String> id,
      Value<String> outletId,
      Value<String> userId,
      Value<int> shiftNumber,
      Value<double> openingCash,
      Value<double?> closingCash,
      Value<double?> expectedCash,
      Value<double?> totalSales,
      Value<String> status,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<int> rowid,
    });

final class $$ShiftsTableReferences
    extends BaseReferences<_$AppDatabase, $ShiftsTable, Shift> {
  $$ShiftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ShiftCashLogsTable, List<ShiftCashLog>>
  _shiftCashLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shiftCashLogs,
    aliasName: 'shifts__id__shift_cash_logs__shift_id',
  );

  $$ShiftCashLogsTableProcessedTableManager get shiftCashLogsRefs {
    final manager = $$ShiftCashLogsTableTableManager(
      $_db,
      $_db.shiftCashLogs,
    ).filter((f) => f.shiftId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shiftCashLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'shifts__id__transactions__shift_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.shiftId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outletId => $composableBuilder(
    column: $table.outletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shiftNumber => $composableBuilder(
    column: $table.shiftNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingCash => $composableBuilder(
    column: $table.openingCash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get closingCash => $composableBuilder(
    column: $table.closingCash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expectedCash => $composableBuilder(
    column: $table.expectedCash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalSales => $composableBuilder(
    column: $table.totalSales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shiftCashLogsRefs(
    Expression<bool> Function($$ShiftCashLogsTableFilterComposer f) f,
  ) {
    final $$ShiftCashLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shiftCashLogs,
      getReferencedColumn: (t) => t.shiftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftCashLogsTableFilterComposer(
            $db: $db,
            $table: $db.shiftCashLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.shiftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outletId => $composableBuilder(
    column: $table.outletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shiftNumber => $composableBuilder(
    column: $table.shiftNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingCash => $composableBuilder(
    column: $table.openingCash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get closingCash => $composableBuilder(
    column: $table.closingCash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expectedCash => $composableBuilder(
    column: $table.expectedCash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalSales => $composableBuilder(
    column: $table.totalSales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get outletId =>
      $composableBuilder(column: $table.outletId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get shiftNumber => $composableBuilder(
    column: $table.shiftNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get openingCash => $composableBuilder(
    column: $table.openingCash,
    builder: (column) => column,
  );

  GeneratedColumn<double> get closingCash => $composableBuilder(
    column: $table.closingCash,
    builder: (column) => column,
  );

  GeneratedColumn<double> get expectedCash => $composableBuilder(
    column: $table.expectedCash,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalSales => $composableBuilder(
    column: $table.totalSales,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  Expression<T> shiftCashLogsRefs<T extends Object>(
    Expression<T> Function($$ShiftCashLogsTableAnnotationComposer a) f,
  ) {
    final $$ShiftCashLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shiftCashLogs,
      getReferencedColumn: (t) => t.shiftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftCashLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.shiftCashLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.shiftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTable,
          Shift,
          $$ShiftsTableFilterComposer,
          $$ShiftsTableOrderingComposer,
          $$ShiftsTableAnnotationComposer,
          $$ShiftsTableCreateCompanionBuilder,
          $$ShiftsTableUpdateCompanionBuilder,
          (Shift, $$ShiftsTableReferences),
          Shift,
          PrefetchHooks Function({
            bool shiftCashLogsRefs,
            bool transactionsRefs,
          })
        > {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> outletId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> shiftNumber = const Value.absent(),
                Value<double> openingCash = const Value.absent(),
                Value<double?> closingCash = const Value.absent(),
                Value<double?> expectedCash = const Value.absent(),
                Value<double?> totalSales = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion(
                id: id,
                outletId: outletId,
                userId: userId,
                shiftNumber: shiftNumber,
                openingCash: openingCash,
                closingCash: closingCash,
                expectedCash: expectedCash,
                totalSales: totalSales,
                status: status,
                openedAt: openedAt,
                closedAt: closedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String outletId,
                required String userId,
                required int shiftNumber,
                required double openingCash,
                Value<double?> closingCash = const Value.absent(),
                Value<double?> expectedCash = const Value.absent(),
                Value<double?> totalSales = const Value.absent(),
                required String status,
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion.insert(
                id: id,
                outletId: outletId,
                userId: userId,
                shiftNumber: shiftNumber,
                openingCash: openingCash,
                closingCash: closingCash,
                expectedCash: expectedCash,
                totalSales: totalSales,
                status: status,
                openedAt: openedAt,
                closedAt: closedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ShiftsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({shiftCashLogsRefs = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (shiftCashLogsRefs) db.shiftCashLogs,
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (shiftCashLogsRefs)
                        await $_getPrefetchedData<
                          Shift,
                          $ShiftsTable,
                          ShiftCashLog
                        >(
                          currentTable: table,
                          referencedTable: $$ShiftsTableReferences
                              ._shiftCashLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShiftsTableReferences(
                                db,
                                table,
                                p0,
                              ).shiftCashLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shiftId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Shift,
                          $ShiftsTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$ShiftsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShiftsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shiftId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTable,
      Shift,
      $$ShiftsTableFilterComposer,
      $$ShiftsTableOrderingComposer,
      $$ShiftsTableAnnotationComposer,
      $$ShiftsTableCreateCompanionBuilder,
      $$ShiftsTableUpdateCompanionBuilder,
      (Shift, $$ShiftsTableReferences),
      Shift,
      PrefetchHooks Function({bool shiftCashLogsRefs, bool transactionsRefs})
    >;
typedef $$ShiftCashLogsTableCreateCompanionBuilder =
    ShiftCashLogsCompanion Function({
      required String id,
      required String shiftId,
      required String type,
      required double amount,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ShiftCashLogsTableUpdateCompanionBuilder =
    ShiftCashLogsCompanion Function({
      Value<String> id,
      Value<String> shiftId,
      Value<String> type,
      Value<double> amount,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ShiftCashLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ShiftCashLogsTable, ShiftCashLog> {
  $$ShiftCashLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ShiftsTable _shiftIdTable(_$AppDatabase db) =>
      db.shifts.createAlias('shift_cash_logs__shift_id__shifts__id');

  $$ShiftsTableProcessedTableManager get shiftId {
    final $_column = $_itemColumn<String>('shift_id')!;

    final manager = $$ShiftsTableTableManager(
      $_db,
      $_db.shifts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shiftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShiftCashLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftCashLogsTable> {
  $$ShiftCashLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ShiftsTableFilterComposer get shiftId {
    final $$ShiftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableFilterComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftCashLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftCashLogsTable> {
  $$ShiftCashLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShiftsTableOrderingComposer get shiftId {
    final $$ShiftsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableOrderingComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftCashLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftCashLogsTable> {
  $$ShiftCashLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ShiftsTableAnnotationComposer get shiftId {
    final $$ShiftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableAnnotationComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftCashLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftCashLogsTable,
          ShiftCashLog,
          $$ShiftCashLogsTableFilterComposer,
          $$ShiftCashLogsTableOrderingComposer,
          $$ShiftCashLogsTableAnnotationComposer,
          $$ShiftCashLogsTableCreateCompanionBuilder,
          $$ShiftCashLogsTableUpdateCompanionBuilder,
          (ShiftCashLog, $$ShiftCashLogsTableReferences),
          ShiftCashLog,
          PrefetchHooks Function({bool shiftId})
        > {
  $$ShiftCashLogsTableTableManager(_$AppDatabase db, $ShiftCashLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftCashLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftCashLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftCashLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shiftId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftCashLogsCompanion(
                id: id,
                shiftId: shiftId,
                type: type,
                amount: amount,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shiftId,
                required String type,
                required double amount,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftCashLogsCompanion.insert(
                id: id,
                shiftId: shiftId,
                type: type,
                amount: amount,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShiftCashLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shiftId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shiftId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shiftId,
                                referencedTable: $$ShiftCashLogsTableReferences
                                    ._shiftIdTable(db),
                                referencedColumn: $$ShiftCashLogsTableReferences
                                    ._shiftIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShiftCashLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftCashLogsTable,
      ShiftCashLog,
      $$ShiftCashLogsTableFilterComposer,
      $$ShiftCashLogsTableOrderingComposer,
      $$ShiftCashLogsTableAnnotationComposer,
      $$ShiftCashLogsTableCreateCompanionBuilder,
      $$ShiftCashLogsTableUpdateCompanionBuilder,
      (ShiftCashLog, $$ShiftCashLogsTableReferences),
      ShiftCashLog,
      PrefetchHooks Function({bool shiftId})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String outletId,
      Value<String?> shiftId,
      Value<String?> customerId,
      required String channel,
      required double subtotal,
      Value<double> discountAmount,
      Value<double> taxAmount,
      Value<double> serviceChargeAmount,
      required double total,
      required String paymentStatus,
      required String status,
      Value<bool> isOffline,
      required String offlineId,
      Value<DateTime?> dueDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> outletId,
      Value<String?> shiftId,
      Value<String?> customerId,
      Value<String> channel,
      Value<double> subtotal,
      Value<double> discountAmount,
      Value<double> taxAmount,
      Value<double> serviceChargeAmount,
      Value<double> total,
      Value<String> paymentStatus,
      Value<String> status,
      Value<bool> isOffline,
      Value<String> offlineId,
      Value<DateTime?> dueDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShiftsTable _shiftIdTable(_$AppDatabase db) =>
      db.shifts.createAlias('transactions__shift_id__shifts__id');

  $$ShiftsTableProcessedTableManager? get shiftId {
    final $_column = $_itemColumn<String>('shift_id');
    if ($_column == null) return null;
    final manager = $$ShiftsTableTableManager(
      $_db,
      $_db.shifts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shiftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionItemsTable, List<TransactionItem>>
  _transactionItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactionItems,
    aliasName: 'transactions__id__transaction_items__transaction_id',
  );

  $$TransactionItemsTableProcessedTableManager get transactionItemsRefs {
    final manager = $$TransactionItemsTableTableManager(
      $_db,
      $_db.transactionItems,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TransactionPaymentsTable,
    List<TransactionPayment>
  >
  _transactionPaymentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionPayments,
        aliasName: 'transactions__id__transaction_payments__transaction_id',
      );

  $$TransactionPaymentsTableProcessedTableManager get transactionPaymentsRefs {
    final manager = $$TransactionPaymentsTableTableManager(
      $_db,
      $_db.transactionPayments,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outletId => $composableBuilder(
    column: $table.outletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get serviceChargeAmount => $composableBuilder(
    column: $table.serviceChargeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOffline => $composableBuilder(
    column: $table.isOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get offlineId => $composableBuilder(
    column: $table.offlineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ShiftsTableFilterComposer get shiftId {
    final $$ShiftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableFilterComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionItemsRefs(
    Expression<bool> Function($$TransactionItemsTableFilterComposer f) f,
  ) {
    final $$TransactionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionItems,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionItemsTableFilterComposer(
            $db: $db,
            $table: $db.transactionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionPaymentsRefs(
    Expression<bool> Function($$TransactionPaymentsTableFilterComposer f) f,
  ) {
    final $$TransactionPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionPayments,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.transactionPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outletId => $composableBuilder(
    column: $table.outletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get serviceChargeAmount => $composableBuilder(
    column: $table.serviceChargeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOffline => $composableBuilder(
    column: $table.isOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get offlineId => $composableBuilder(
    column: $table.offlineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShiftsTableOrderingComposer get shiftId {
    final $$ShiftsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableOrderingComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get outletId =>
      $composableBuilder(column: $table.outletId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get serviceChargeAmount => $composableBuilder(
    column: $table.serviceChargeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isOffline =>
      $composableBuilder(column: $table.isOffline, builder: (column) => column);

  GeneratedColumn<String> get offlineId =>
      $composableBuilder(column: $table.offlineId, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ShiftsTableAnnotationComposer get shiftId {
    final $$ShiftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableAnnotationComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionItemsRefs<T extends Object>(
    Expression<T> Function($$TransactionItemsTableAnnotationComposer a) f,
  ) {
    final $$TransactionItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionItems,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionPaymentsRefs<T extends Object>(
    Expression<T> Function($$TransactionPaymentsTableAnnotationComposer a) f,
  ) {
    final $$TransactionPaymentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionPayments,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionPaymentsTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionPayments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({
            bool shiftId,
            bool transactionItemsRefs,
            bool transactionPaymentsRefs,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> outletId = const Value.absent(),
                Value<String?> shiftId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> serviceChargeAmount = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isOffline = const Value.absent(),
                Value<String> offlineId = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                outletId: outletId,
                shiftId: shiftId,
                customerId: customerId,
                channel: channel,
                subtotal: subtotal,
                discountAmount: discountAmount,
                taxAmount: taxAmount,
                serviceChargeAmount: serviceChargeAmount,
                total: total,
                paymentStatus: paymentStatus,
                status: status,
                isOffline: isOffline,
                offlineId: offlineId,
                dueDate: dueDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String outletId,
                Value<String?> shiftId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                required String channel,
                required double subtotal,
                Value<double> discountAmount = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> serviceChargeAmount = const Value.absent(),
                required double total,
                required String paymentStatus,
                required String status,
                Value<bool> isOffline = const Value.absent(),
                required String offlineId,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                outletId: outletId,
                shiftId: shiftId,
                customerId: customerId,
                channel: channel,
                subtotal: subtotal,
                discountAmount: discountAmount,
                taxAmount: taxAmount,
                serviceChargeAmount: serviceChargeAmount,
                total: total,
                paymentStatus: paymentStatus,
                status: status,
                isOffline: isOffline,
                offlineId: offlineId,
                dueDate: dueDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shiftId = false,
                transactionItemsRefs = false,
                transactionPaymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionItemsRefs) db.transactionItems,
                    if (transactionPaymentsRefs) db.transactionPayments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shiftId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shiftId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._shiftIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._shiftIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionItemsRefs)
                        await $_getPrefetchedData<
                          Transaction,
                          $TransactionsTable,
                          TransactionItem
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._transactionItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionPaymentsRefs)
                        await $_getPrefetchedData<
                          Transaction,
                          $TransactionsTable,
                          TransactionPayment
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._transactionPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({
        bool shiftId,
        bool transactionItemsRefs,
        bool transactionPaymentsRefs,
      })
    >;
typedef $$TransactionItemsTableCreateCompanionBuilder =
    TransactionItemsCompanion Function({
      required String id,
      required String transactionId,
      required String productId,
      required String productName,
      required double price,
      required double qty,
      Value<double> discountAmount,
      required double subtotal,
      Value<int> rowid,
    });
typedef $$TransactionItemsTableUpdateCompanionBuilder =
    TransactionItemsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String> productId,
      Value<String> productName,
      Value<double> price,
      Value<double> qty,
      Value<double> discountAmount,
      Value<double> subtotal,
      Value<int> rowid,
    });

final class $$TransactionItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TransactionItemsTable, TransactionItem> {
  $$TransactionItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) => db
      .transactions
      .createAlias('transaction_items__transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $TransactionItemModifiersTable,
    List<TransactionItemModifier>
  >
  _transactionItemModifiersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.transactionItemModifiers,
    aliasName:
        'transaction_items__id__transaction_item_modifiers__transaction_item_id',
  );

  $$TransactionItemModifiersTableProcessedTableManager
  get transactionItemModifiersRefs {
    final manager =
        $$TransactionItemModifiersTableTableManager(
          $_db,
          $_db.transactionItemModifiers,
        ).filter(
          (f) => f.transactionItemId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _transactionItemModifiersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionItemModifiersRefs(
    Expression<bool> Function($$TransactionItemModifiersTableFilterComposer f)
    f,
  ) {
    final $$TransactionItemModifiersTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionItemModifiers,
          getReferencedColumn: (t) => t.transactionItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionItemModifiersTableFilterComposer(
                $db: $db,
                $table: $db.transactionItemModifiers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransactionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionItemModifiersRefs<T extends Object>(
    Expression<T> Function($$TransactionItemModifiersTableAnnotationComposer a)
    f,
  ) {
    final $$TransactionItemModifiersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionItemModifiers,
          getReferencedColumn: (t) => t.transactionItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionItemModifiersTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionItemModifiers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransactionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionItemsTable,
          TransactionItem,
          $$TransactionItemsTableFilterComposer,
          $$TransactionItemsTableOrderingComposer,
          $$TransactionItemsTableAnnotationComposer,
          $$TransactionItemsTableCreateCompanionBuilder,
          $$TransactionItemsTableUpdateCompanionBuilder,
          (TransactionItem, $$TransactionItemsTableReferences),
          TransactionItem,
          PrefetchHooks Function({
            bool transactionId,
            bool transactionItemModifiersRefs,
          })
        > {
  $$TransactionItemsTableTableManager(
    _$AppDatabase db,
    $TransactionItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double> qty = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemsCompanion(
                id: id,
                transactionId: transactionId,
                productId: productId,
                productName: productName,
                price: price,
                qty: qty,
                discountAmount: discountAmount,
                subtotal: subtotal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                required String productId,
                required String productName,
                required double price,
                required double qty,
                Value<double> discountAmount = const Value.absent(),
                required double subtotal,
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemsCompanion.insert(
                id: id,
                transactionId: transactionId,
                productId: productId,
                productName: productName,
                price: price,
                qty: qty,
                discountAmount: discountAmount,
                subtotal: subtotal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transactionId = false, transactionItemModifiersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionItemModifiersRefs)
                      db.transactionItemModifiers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (transactionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.transactionId,
                                    referencedTable:
                                        $$TransactionItemsTableReferences
                                            ._transactionIdTable(db),
                                    referencedColumn:
                                        $$TransactionItemsTableReferences
                                            ._transactionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionItemModifiersRefs)
                        await $_getPrefetchedData<
                          TransactionItem,
                          $TransactionItemsTable,
                          TransactionItemModifier
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionItemsTableReferences
                              ._transactionItemModifiersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionItemModifiersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionItemsTable,
      TransactionItem,
      $$TransactionItemsTableFilterComposer,
      $$TransactionItemsTableOrderingComposer,
      $$TransactionItemsTableAnnotationComposer,
      $$TransactionItemsTableCreateCompanionBuilder,
      $$TransactionItemsTableUpdateCompanionBuilder,
      (TransactionItem, $$TransactionItemsTableReferences),
      TransactionItem,
      PrefetchHooks Function({
        bool transactionId,
        bool transactionItemModifiersRefs,
      })
    >;
typedef $$TransactionItemModifiersTableCreateCompanionBuilder =
    TransactionItemModifiersCompanion Function({
      required String id,
      required String transactionItemId,
      required String modifierName,
      required double priceAdjustment,
      Value<int> rowid,
    });
typedef $$TransactionItemModifiersTableUpdateCompanionBuilder =
    TransactionItemModifiersCompanion Function({
      Value<String> id,
      Value<String> transactionItemId,
      Value<String> modifierName,
      Value<double> priceAdjustment,
      Value<int> rowid,
    });

final class $$TransactionItemModifiersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionItemModifiersTable,
          TransactionItemModifier
        > {
  $$TransactionItemModifiersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionItemsTable _transactionItemIdTable(
    _$AppDatabase db,
  ) => db.transactionItems.createAlias(
    'transaction_item_modifiers__transaction_item_id__transaction_items__id',
  );

  $$TransactionItemsTableProcessedTableManager get transactionItemId {
    final $_column = $_itemColumn<String>('transaction_item_id')!;

    final manager = $$TransactionItemsTableTableManager(
      $_db,
      $_db.transactionItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionItemModifiersTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionItemModifiersTable> {
  $$TransactionItemModifiersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifierName => $composableBuilder(
    column: $table.modifierName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priceAdjustment => $composableBuilder(
    column: $table.priceAdjustment,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionItemsTableFilterComposer get transactionItemId {
    final $$TransactionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionItemId,
      referencedTable: $db.transactionItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionItemsTableFilterComposer(
            $db: $db,
            $table: $db.transactionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionItemModifiersTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionItemModifiersTable> {
  $$TransactionItemModifiersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifierName => $composableBuilder(
    column: $table.modifierName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priceAdjustment => $composableBuilder(
    column: $table.priceAdjustment,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionItemsTableOrderingComposer get transactionItemId {
    final $$TransactionItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionItemId,
      referencedTable: $db.transactionItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionItemsTableOrderingComposer(
            $db: $db,
            $table: $db.transactionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionItemModifiersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionItemModifiersTable> {
  $$TransactionItemModifiersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modifierName => $composableBuilder(
    column: $table.modifierName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get priceAdjustment => $composableBuilder(
    column: $table.priceAdjustment,
    builder: (column) => column,
  );

  $$TransactionItemsTableAnnotationComposer get transactionItemId {
    final $$TransactionItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionItemId,
      referencedTable: $db.transactionItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionItemModifiersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionItemModifiersTable,
          TransactionItemModifier,
          $$TransactionItemModifiersTableFilterComposer,
          $$TransactionItemModifiersTableOrderingComposer,
          $$TransactionItemModifiersTableAnnotationComposer,
          $$TransactionItemModifiersTableCreateCompanionBuilder,
          $$TransactionItemModifiersTableUpdateCompanionBuilder,
          (TransactionItemModifier, $$TransactionItemModifiersTableReferences),
          TransactionItemModifier,
          PrefetchHooks Function({bool transactionItemId})
        > {
  $$TransactionItemModifiersTableTableManager(
    _$AppDatabase db,
    $TransactionItemModifiersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionItemModifiersTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TransactionItemModifiersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TransactionItemModifiersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionItemId = const Value.absent(),
                Value<String> modifierName = const Value.absent(),
                Value<double> priceAdjustment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemModifiersCompanion(
                id: id,
                transactionItemId: transactionItemId,
                modifierName: modifierName,
                priceAdjustment: priceAdjustment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionItemId,
                required String modifierName,
                required double priceAdjustment,
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemModifiersCompanion.insert(
                id: id,
                transactionItemId: transactionItemId,
                modifierName: modifierName,
                priceAdjustment: priceAdjustment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionItemModifiersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transactionItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionItemId,
                                referencedTable:
                                    $$TransactionItemModifiersTableReferences
                                        ._transactionItemIdTable(db),
                                referencedColumn:
                                    $$TransactionItemModifiersTableReferences
                                        ._transactionItemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionItemModifiersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionItemModifiersTable,
      TransactionItemModifier,
      $$TransactionItemModifiersTableFilterComposer,
      $$TransactionItemModifiersTableOrderingComposer,
      $$TransactionItemModifiersTableAnnotationComposer,
      $$TransactionItemModifiersTableCreateCompanionBuilder,
      $$TransactionItemModifiersTableUpdateCompanionBuilder,
      (TransactionItemModifier, $$TransactionItemModifiersTableReferences),
      TransactionItemModifier,
      PrefetchHooks Function({bool transactionItemId})
    >;
typedef $$TransactionPaymentsTableCreateCompanionBuilder =
    TransactionPaymentsCompanion Function({
      required String id,
      required String transactionId,
      required String paymentMethodId,
      required double amount,
      Value<double> changeAmount,
      Value<DateTime> paidAt,
      Value<int> rowid,
    });
typedef $$TransactionPaymentsTableUpdateCompanionBuilder =
    TransactionPaymentsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String> paymentMethodId,
      Value<double> amount,
      Value<double> changeAmount,
      Value<DateTime> paidAt,
      Value<int> rowid,
    });

final class $$TransactionPaymentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionPaymentsTable,
          TransactionPayment
        > {
  $$TransactionPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) => db
      .transactions
      .createAlias('transaction_payments__transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PaymentMethodsTable _paymentMethodIdTable(_$AppDatabase db) =>
      db.paymentMethods.createAlias(
        'transaction_payments__payment_method_id__payment_methods__id',
      );

  $$PaymentMethodsTableProcessedTableManager get paymentMethodId {
    final $_column = $_itemColumn<String>('payment_method_id')!;

    final manager = $$PaymentMethodsTableTableManager(
      $_db,
      $_db.paymentMethods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentMethodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionPaymentsTable> {
  $$TransactionPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableFilterComposer get paymentMethodId {
    final $$PaymentMethodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableFilterComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionPaymentsTable> {
  $$TransactionPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableOrderingComposer get paymentMethodId {
    final $$PaymentMethodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableOrderingComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionPaymentsTable> {
  $$TransactionPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableAnnotationComposer get paymentMethodId {
    final $$PaymentMethodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionPaymentsTable,
          TransactionPayment,
          $$TransactionPaymentsTableFilterComposer,
          $$TransactionPaymentsTableOrderingComposer,
          $$TransactionPaymentsTableAnnotationComposer,
          $$TransactionPaymentsTableCreateCompanionBuilder,
          $$TransactionPaymentsTableUpdateCompanionBuilder,
          (TransactionPayment, $$TransactionPaymentsTableReferences),
          TransactionPayment,
          PrefetchHooks Function({bool transactionId, bool paymentMethodId})
        > {
  $$TransactionPaymentsTableTableManager(
    _$AppDatabase db,
    $TransactionPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionPaymentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TransactionPaymentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> paymentMethodId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> changeAmount = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionPaymentsCompanion(
                id: id,
                transactionId: transactionId,
                paymentMethodId: paymentMethodId,
                amount: amount,
                changeAmount: changeAmount,
                paidAt: paidAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                required String paymentMethodId,
                required double amount,
                Value<double> changeAmount = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionPaymentsCompanion.insert(
                id: id,
                transactionId: transactionId,
                paymentMethodId: paymentMethodId,
                amount: amount,
                changeAmount: changeAmount,
                paidAt: paidAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transactionId = false, paymentMethodId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (transactionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.transactionId,
                                    referencedTable:
                                        $$TransactionPaymentsTableReferences
                                            ._transactionIdTable(db),
                                    referencedColumn:
                                        $$TransactionPaymentsTableReferences
                                            ._transactionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (paymentMethodId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.paymentMethodId,
                                    referencedTable:
                                        $$TransactionPaymentsTableReferences
                                            ._paymentMethodIdTable(db),
                                    referencedColumn:
                                        $$TransactionPaymentsTableReferences
                                            ._paymentMethodIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionPaymentsTable,
      TransactionPayment,
      $$TransactionPaymentsTableFilterComposer,
      $$TransactionPaymentsTableOrderingComposer,
      $$TransactionPaymentsTableAnnotationComposer,
      $$TransactionPaymentsTableCreateCompanionBuilder,
      $$TransactionPaymentsTableUpdateCompanionBuilder,
      (TransactionPayment, $$TransactionPaymentsTableReferences),
      TransactionPayment,
      PrefetchHooks Function({bool transactionId, bool paymentMethodId})
    >;
typedef $$EmployeesTableCreateCompanionBuilder =
    EmployeesCompanion Function({
      required String id,
      required String name,
      Value<String?> email,
      Value<String?> pin,
      Value<String?> photo,
      Value<String?> role,
      Value<int> rowid,
    });
typedef $$EmployeesTableUpdateCompanionBuilder =
    EmployeesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> email,
      Value<String?> pin,
      Value<String?> photo,
      Value<String?> role,
      Value<int> rowid,
    });

class $$EmployeesTableFilterComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pin => $composableBuilder(
    column: $table.pin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmployeesTableOrderingComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pin => $composableBuilder(
    column: $table.pin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmployeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get pin =>
      $composableBuilder(column: $table.pin, builder: (column) => column);

  GeneratedColumn<String> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$EmployeesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmployeesTable,
          Employee,
          $$EmployeesTableFilterComposer,
          $$EmployeesTableOrderingComposer,
          $$EmployeesTableAnnotationComposer,
          $$EmployeesTableCreateCompanionBuilder,
          $$EmployeesTableUpdateCompanionBuilder,
          (Employee, BaseReferences<_$AppDatabase, $EmployeesTable, Employee>),
          Employee,
          PrefetchHooks Function()
        > {
  $$EmployeesTableTableManager(_$AppDatabase db, $EmployeesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmployeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmployeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmployeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> pin = const Value.absent(),
                Value<String?> photo = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion(
                id: id,
                name: name,
                email: email,
                pin: pin,
                photo: photo,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> email = const Value.absent(),
                Value<String?> pin = const Value.absent(),
                Value<String?> photo = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion.insert(
                id: id,
                name: name,
                email: email,
                pin: pin,
                photo: photo,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmployeesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmployeesTable,
      Employee,
      $$EmployeesTableFilterComposer,
      $$EmployeesTableOrderingComposer,
      $$EmployeesTableAnnotationComposer,
      $$EmployeesTableCreateCompanionBuilder,
      $$EmployeesTableUpdateCompanionBuilder,
      (Employee, BaseReferences<_$AppDatabase, $EmployeesTable, Employee>),
      Employee,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$VariantsTableTableManager get variants =>
      $$VariantsTableTableManager(_db, _db.variants);
  $$InventoriesTableTableManager get inventories =>
      $$InventoriesTableTableManager(_db, _db.inventories);
  $$PaymentMethodsTableTableManager get paymentMethods =>
      $$PaymentMethodsTableTableManager(_db, _db.paymentMethods);
  $$OutletSettingsTableTableManager get outletSettings =>
      $$OutletSettingsTableTableManager(_db, _db.outletSettings);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$ShiftCashLogsTableTableManager get shiftCashLogs =>
      $$ShiftCashLogsTableTableManager(_db, _db.shiftCashLogs);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TransactionItemsTableTableManager get transactionItems =>
      $$TransactionItemsTableTableManager(_db, _db.transactionItems);
  $$TransactionItemModifiersTableTableManager get transactionItemModifiers =>
      $$TransactionItemModifiersTableTableManager(
        _db,
        _db.transactionItemModifiers,
      );
  $$TransactionPaymentsTableTableManager get transactionPayments =>
      $$TransactionPaymentsTableTableManager(_db, _db.transactionPayments);
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db, _db.employees);
}
