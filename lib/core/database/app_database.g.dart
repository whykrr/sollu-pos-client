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

class $ProductCategoriesTable extends ProductCategories
    with TableInfo<$ProductCategoriesTable, ProductCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductCategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, parentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductCategory> instance, {
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
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
    );
  }

  @override
  $ProductCategoriesTable createAlias(String alias) {
    return $ProductCategoriesTable(attachedDatabase, alias);
  }
}

class ProductCategory extends DataClass implements Insertable<ProductCategory> {
  final String id;
  final String name;
  final String? parentId;
  const ProductCategory({required this.id, required this.name, this.parentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    return map;
  }

  ProductCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ProductCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory ProductCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
    };
  }

  ProductCategory copyWith({
    String? id,
    String? name,
    Value<String?> parentId = const Value.absent(),
  }) => ProductCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
  );
  ProductCategory copyWithCompanion(ProductCategoriesCompanion data) {
    return ProductCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId);
}

class ProductCategoriesCompanion extends UpdateCompanion<ProductCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<int> rowid;
  const ProductCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductCategoriesCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ProductCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? parentId,
    Value<int>? rowid,
  }) {
    return ProductCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
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
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VariantGroupsTable extends VariantGroups
    with TableInfo<$VariantGroupsTable, VariantGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VariantGroupsTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [id, productId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'variant_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<VariantGroup> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VariantGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VariantGroup(
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
    );
  }

  @override
  $VariantGroupsTable createAlias(String alias) {
    return $VariantGroupsTable(attachedDatabase, alias);
  }
}

class VariantGroup extends DataClass implements Insertable<VariantGroup> {
  final String id;
  final String productId;
  final String name;
  const VariantGroup({
    required this.id,
    required this.productId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['name'] = Variable<String>(name);
    return map;
  }

  VariantGroupsCompanion toCompanion(bool nullToAbsent) {
    return VariantGroupsCompanion(
      id: Value(id),
      productId: Value(productId),
      name: Value(name),
    );
  }

  factory VariantGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VariantGroup(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'name': serializer.toJson<String>(name),
    };
  }

  VariantGroup copyWith({String? id, String? productId, String? name}) =>
      VariantGroup(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        name: name ?? this.name,
      );
  VariantGroup copyWithCompanion(VariantGroupsCompanion data) {
    return VariantGroup(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VariantGroup(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VariantGroup &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.name == this.name);
}

class VariantGroupsCompanion extends UpdateCompanion<VariantGroup> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> name;
  final Value<int> rowid;
  const VariantGroupsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VariantGroupsCompanion.insert({
    required String id,
    required String productId,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       name = Value(name);
  static Insertable<VariantGroup> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VariantGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return VariantGroupsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VariantGroupsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VariantGroupOptionsTable extends VariantGroupOptions
    with TableInfo<$VariantGroupOptionsTable, VariantGroupOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VariantGroupOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantGroupIdMeta = const VerificationMeta(
    'variantGroupId',
  );
  @override
  late final GeneratedColumn<String> variantGroupId = GeneratedColumn<String>(
    'variant_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES variant_groups (id)',
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
  @override
  List<GeneratedColumn> get $columns => [id, variantGroupId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'variant_group_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<VariantGroupOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('variant_group_id')) {
      context.handle(
        _variantGroupIdMeta,
        variantGroupId.isAcceptableOrUnknown(
          data['variant_group_id']!,
          _variantGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_variantGroupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VariantGroupOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VariantGroupOption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      variantGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_group_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $VariantGroupOptionsTable createAlias(String alias) {
    return $VariantGroupOptionsTable(attachedDatabase, alias);
  }
}

class VariantGroupOption extends DataClass
    implements Insertable<VariantGroupOption> {
  final String id;
  final String variantGroupId;
  final String name;
  const VariantGroupOption({
    required this.id,
    required this.variantGroupId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['variant_group_id'] = Variable<String>(variantGroupId);
    map['name'] = Variable<String>(name);
    return map;
  }

  VariantGroupOptionsCompanion toCompanion(bool nullToAbsent) {
    return VariantGroupOptionsCompanion(
      id: Value(id),
      variantGroupId: Value(variantGroupId),
      name: Value(name),
    );
  }

  factory VariantGroupOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VariantGroupOption(
      id: serializer.fromJson<String>(json['id']),
      variantGroupId: serializer.fromJson<String>(json['variantGroupId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'variantGroupId': serializer.toJson<String>(variantGroupId),
      'name': serializer.toJson<String>(name),
    };
  }

  VariantGroupOption copyWith({
    String? id,
    String? variantGroupId,
    String? name,
  }) => VariantGroupOption(
    id: id ?? this.id,
    variantGroupId: variantGroupId ?? this.variantGroupId,
    name: name ?? this.name,
  );
  VariantGroupOption copyWithCompanion(VariantGroupOptionsCompanion data) {
    return VariantGroupOption(
      id: data.id.present ? data.id.value : this.id,
      variantGroupId: data.variantGroupId.present
          ? data.variantGroupId.value
          : this.variantGroupId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VariantGroupOption(')
          ..write('id: $id, ')
          ..write('variantGroupId: $variantGroupId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, variantGroupId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VariantGroupOption &&
          other.id == this.id &&
          other.variantGroupId == this.variantGroupId &&
          other.name == this.name);
}

class VariantGroupOptionsCompanion extends UpdateCompanion<VariantGroupOption> {
  final Value<String> id;
  final Value<String> variantGroupId;
  final Value<String> name;
  final Value<int> rowid;
  const VariantGroupOptionsCompanion({
    this.id = const Value.absent(),
    this.variantGroupId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VariantGroupOptionsCompanion.insert({
    required String id,
    required String variantGroupId,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       variantGroupId = Value(variantGroupId),
       name = Value(name);
  static Insertable<VariantGroupOption> custom({
    Expression<String>? id,
    Expression<String>? variantGroupId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (variantGroupId != null) 'variant_group_id': variantGroupId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VariantGroupOptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? variantGroupId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return VariantGroupOptionsCompanion(
      id: id ?? this.id,
      variantGroupId: variantGroupId ?? this.variantGroupId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (variantGroupId.present) {
      map['variant_group_id'] = Variable<String>(variantGroupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VariantGroupOptionsCompanion(')
          ..write('id: $id, ')
          ..write('variantGroupId: $variantGroupId, ')
          ..write('name: $name, ')
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
  static const VerificationMeta _trackInventoryMeta = const VerificationMeta(
    'trackInventory',
  );
  @override
  late final GeneratedColumn<bool> trackInventory = GeneratedColumn<bool>(
    'track_inventory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("track_inventory" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    name,
    sku,
    barcode,
    trackInventory,
    isActive,
    stock,
  ];
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
    if (data.containsKey('track_inventory')) {
      context.handle(
        _trackInventoryMeta,
        trackInventory.isAcceptableOrUnknown(
          data['track_inventory']!,
          _trackInventoryMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Inventory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Inventory(
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
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      trackInventory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}track_inventory'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
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
  final String id;
  final String productId;
  final String name;
  final String? sku;
  final String? barcode;
  final bool trackInventory;
  final bool isActive;
  final double stock;
  const Inventory({
    required this.id,
    required this.productId,
    required this.name,
    this.sku,
    this.barcode,
    required this.trackInventory,
    required this.isActive,
    required this.stock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['track_inventory'] = Variable<bool>(trackInventory);
    map['is_active'] = Variable<bool>(isActive);
    map['stock'] = Variable<double>(stock);
    return map;
  }

  InventoriesCompanion toCompanion(bool nullToAbsent) {
    return InventoriesCompanion(
      id: Value(id),
      productId: Value(productId),
      name: Value(name),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      trackInventory: Value(trackInventory),
      isActive: Value(isActive),
      stock: Value(stock),
    );
  }

  factory Inventory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Inventory(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String?>(json['sku']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      trackInventory: serializer.fromJson<bool>(json['trackInventory']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      stock: serializer.fromJson<double>(json['stock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String?>(sku),
      'barcode': serializer.toJson<String?>(barcode),
      'trackInventory': serializer.toJson<bool>(trackInventory),
      'isActive': serializer.toJson<bool>(isActive),
      'stock': serializer.toJson<double>(stock),
    };
  }

  Inventory copyWith({
    String? id,
    String? productId,
    String? name,
    Value<String?> sku = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    bool? trackInventory,
    bool? isActive,
    double? stock,
  }) => Inventory(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    name: name ?? this.name,
    sku: sku.present ? sku.value : this.sku,
    barcode: barcode.present ? barcode.value : this.barcode,
    trackInventory: trackInventory ?? this.trackInventory,
    isActive: isActive ?? this.isActive,
    stock: stock ?? this.stock,
  );
  Inventory copyWithCompanion(InventoriesCompanion data) {
    return Inventory(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      trackInventory: data.trackInventory.present
          ? data.trackInventory.value
          : this.trackInventory,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      stock: data.stock.present ? data.stock.value : this.stock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Inventory(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('trackInventory: $trackInventory, ')
          ..write('isActive: $isActive, ')
          ..write('stock: $stock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    name,
    sku,
    barcode,
    trackInventory,
    isActive,
    stock,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Inventory &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.barcode == this.barcode &&
          other.trackInventory == this.trackInventory &&
          other.isActive == this.isActive &&
          other.stock == this.stock);
}

class InventoriesCompanion extends UpdateCompanion<Inventory> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> name;
  final Value<String?> sku;
  final Value<String?> barcode;
  final Value<bool> trackInventory;
  final Value<bool> isActive;
  final Value<double> stock;
  final Value<int> rowid;
  const InventoriesCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.trackInventory = const Value.absent(),
    this.isActive = const Value.absent(),
    this.stock = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoriesCompanion.insert({
    required String id,
    required String productId,
    required String name,
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.trackInventory = const Value.absent(),
    this.isActive = const Value.absent(),
    this.stock = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       name = Value(name);
  static Insertable<Inventory> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? barcode,
    Expression<bool>? trackInventory,
    Expression<bool>? isActive,
    Expression<double>? stock,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (trackInventory != null) 'track_inventory': trackInventory,
      if (isActive != null) 'is_active': isActive,
      if (stock != null) 'stock': stock,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? name,
    Value<String?>? sku,
    Value<String?>? barcode,
    Value<bool>? trackInventory,
    Value<bool>? isActive,
    Value<double>? stock,
    Value<int>? rowid,
  }) {
    return InventoriesCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      trackInventory: trackInventory ?? this.trackInventory,
      isActive: isActive ?? this.isActive,
      stock: stock ?? this.stock,
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
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (trackInventory.present) {
      map['track_inventory'] = Variable<bool>(trackInventory.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('trackInventory: $trackInventory, ')
          ..write('isActive: $isActive, ')
          ..write('stock: $stock, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryItemVariantGroupOptionsTable
    extends InventoryItemVariantGroupOptions
    with
        TableInfo<
          $InventoryItemVariantGroupOptionsTable,
          InventoryItemVariantGroupOption
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryItemVariantGroupOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _inventoryItemIdMeta = const VerificationMeta(
    'inventoryItemId',
  );
  @override
  late final GeneratedColumn<String> inventoryItemId = GeneratedColumn<String>(
    'inventory_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES inventories (id)',
    ),
  );
  static const VerificationMeta _variantGroupOptionIdMeta =
      const VerificationMeta('variantGroupOptionId');
  @override
  late final GeneratedColumn<String> variantGroupOptionId =
      GeneratedColumn<String>(
        'variant_group_option_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES variant_group_options (id)',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [inventoryItemId, variantGroupOptionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_item_variant_group_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryItemVariantGroupOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('inventory_item_id')) {
      context.handle(
        _inventoryItemIdMeta,
        inventoryItemId.isAcceptableOrUnknown(
          data['inventory_item_id']!,
          _inventoryItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inventoryItemIdMeta);
    }
    if (data.containsKey('variant_group_option_id')) {
      context.handle(
        _variantGroupOptionIdMeta,
        variantGroupOptionId.isAcceptableOrUnknown(
          data['variant_group_option_id']!,
          _variantGroupOptionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_variantGroupOptionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    inventoryItemId,
    variantGroupOptionId,
  };
  @override
  InventoryItemVariantGroupOption map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryItemVariantGroupOption(
      inventoryItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inventory_item_id'],
      )!,
      variantGroupOptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_group_option_id'],
      )!,
    );
  }

  @override
  $InventoryItemVariantGroupOptionsTable createAlias(String alias) {
    return $InventoryItemVariantGroupOptionsTable(attachedDatabase, alias);
  }
}

class InventoryItemVariantGroupOption extends DataClass
    implements Insertable<InventoryItemVariantGroupOption> {
  final String inventoryItemId;
  final String variantGroupOptionId;
  const InventoryItemVariantGroupOption({
    required this.inventoryItemId,
    required this.variantGroupOptionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['inventory_item_id'] = Variable<String>(inventoryItemId);
    map['variant_group_option_id'] = Variable<String>(variantGroupOptionId);
    return map;
  }

  InventoryItemVariantGroupOptionsCompanion toCompanion(bool nullToAbsent) {
    return InventoryItemVariantGroupOptionsCompanion(
      inventoryItemId: Value(inventoryItemId),
      variantGroupOptionId: Value(variantGroupOptionId),
    );
  }

  factory InventoryItemVariantGroupOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryItemVariantGroupOption(
      inventoryItemId: serializer.fromJson<String>(json['inventoryItemId']),
      variantGroupOptionId: serializer.fromJson<String>(
        json['variantGroupOptionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'inventoryItemId': serializer.toJson<String>(inventoryItemId),
      'variantGroupOptionId': serializer.toJson<String>(variantGroupOptionId),
    };
  }

  InventoryItemVariantGroupOption copyWith({
    String? inventoryItemId,
    String? variantGroupOptionId,
  }) => InventoryItemVariantGroupOption(
    inventoryItemId: inventoryItemId ?? this.inventoryItemId,
    variantGroupOptionId: variantGroupOptionId ?? this.variantGroupOptionId,
  );
  InventoryItemVariantGroupOption copyWithCompanion(
    InventoryItemVariantGroupOptionsCompanion data,
  ) {
    return InventoryItemVariantGroupOption(
      inventoryItemId: data.inventoryItemId.present
          ? data.inventoryItemId.value
          : this.inventoryItemId,
      variantGroupOptionId: data.variantGroupOptionId.present
          ? data.variantGroupOptionId.value
          : this.variantGroupOptionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemVariantGroupOption(')
          ..write('inventoryItemId: $inventoryItemId, ')
          ..write('variantGroupOptionId: $variantGroupOptionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(inventoryItemId, variantGroupOptionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryItemVariantGroupOption &&
          other.inventoryItemId == this.inventoryItemId &&
          other.variantGroupOptionId == this.variantGroupOptionId);
}

class InventoryItemVariantGroupOptionsCompanion
    extends UpdateCompanion<InventoryItemVariantGroupOption> {
  final Value<String> inventoryItemId;
  final Value<String> variantGroupOptionId;
  final Value<int> rowid;
  const InventoryItemVariantGroupOptionsCompanion({
    this.inventoryItemId = const Value.absent(),
    this.variantGroupOptionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryItemVariantGroupOptionsCompanion.insert({
    required String inventoryItemId,
    required String variantGroupOptionId,
    this.rowid = const Value.absent(),
  }) : inventoryItemId = Value(inventoryItemId),
       variantGroupOptionId = Value(variantGroupOptionId);
  static Insertable<InventoryItemVariantGroupOption> custom({
    Expression<String>? inventoryItemId,
    Expression<String>? variantGroupOptionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (inventoryItemId != null) 'inventory_item_id': inventoryItemId,
      if (variantGroupOptionId != null)
        'variant_group_option_id': variantGroupOptionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryItemVariantGroupOptionsCompanion copyWith({
    Value<String>? inventoryItemId,
    Value<String>? variantGroupOptionId,
    Value<int>? rowid,
  }) {
    return InventoryItemVariantGroupOptionsCompanion(
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      variantGroupOptionId: variantGroupOptionId ?? this.variantGroupOptionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (inventoryItemId.present) {
      map['inventory_item_id'] = Variable<String>(inventoryItemId.value);
    }
    if (variantGroupOptionId.present) {
      map['variant_group_option_id'] = Variable<String>(
        variantGroupOptionId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemVariantGroupOptionsCompanion(')
          ..write('inventoryItemId: $inventoryItemId, ')
          ..write('variantGroupOptionId: $variantGroupOptionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModifierGroupsTable extends ModifierGroups
    with TableInfo<$ModifierGroupsTable, ModifierGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModifierGroupsTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minSelectedMeta = const VerificationMeta(
    'minSelected',
  );
  @override
  late final GeneratedColumn<int> minSelected = GeneratedColumn<int>(
    'min_selected',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxSelectedMeta = const VerificationMeta(
    'maxSelected',
  );
  @override
  late final GeneratedColumn<int> maxSelected = GeneratedColumn<int>(
    'max_selected',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    minSelected,
    maxSelected,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'modifier_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModifierGroup> instance, {
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
    }
    if (data.containsKey('min_selected')) {
      context.handle(
        _minSelectedMeta,
        minSelected.isAcceptableOrUnknown(
          data['min_selected']!,
          _minSelectedMeta,
        ),
      );
    }
    if (data.containsKey('max_selected')) {
      context.handle(
        _maxSelectedMeta,
        maxSelected.isAcceptableOrUnknown(
          data['max_selected']!,
          _maxSelectedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModifierGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModifierGroup(
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
      ),
      minSelected: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_selected'],
      )!,
      maxSelected: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_selected'],
      )!,
    );
  }

  @override
  $ModifierGroupsTable createAlias(String alias) {
    return $ModifierGroupsTable(attachedDatabase, alias);
  }
}

class ModifierGroup extends DataClass implements Insertable<ModifierGroup> {
  final String id;
  final String name;
  final String? type;
  final int minSelected;
  final int maxSelected;
  const ModifierGroup({
    required this.id,
    required this.name,
    this.type,
    required this.minSelected,
    required this.maxSelected,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    map['min_selected'] = Variable<int>(minSelected);
    map['max_selected'] = Variable<int>(maxSelected);
    return map;
  }

  ModifierGroupsCompanion toCompanion(bool nullToAbsent) {
    return ModifierGroupsCompanion(
      id: Value(id),
      name: Value(name),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      minSelected: Value(minSelected),
      maxSelected: Value(maxSelected),
    );
  }

  factory ModifierGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModifierGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String?>(json['type']),
      minSelected: serializer.fromJson<int>(json['minSelected']),
      maxSelected: serializer.fromJson<int>(json['maxSelected']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String?>(type),
      'minSelected': serializer.toJson<int>(minSelected),
      'maxSelected': serializer.toJson<int>(maxSelected),
    };
  }

  ModifierGroup copyWith({
    String? id,
    String? name,
    Value<String?> type = const Value.absent(),
    int? minSelected,
    int? maxSelected,
  }) => ModifierGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type.present ? type.value : this.type,
    minSelected: minSelected ?? this.minSelected,
    maxSelected: maxSelected ?? this.maxSelected,
  );
  ModifierGroup copyWithCompanion(ModifierGroupsCompanion data) {
    return ModifierGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      minSelected: data.minSelected.present
          ? data.minSelected.value
          : this.minSelected,
      maxSelected: data.maxSelected.present
          ? data.maxSelected.value
          : this.maxSelected,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModifierGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('minSelected: $minSelected, ')
          ..write('maxSelected: $maxSelected')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, minSelected, maxSelected);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModifierGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.minSelected == this.minSelected &&
          other.maxSelected == this.maxSelected);
}

class ModifierGroupsCompanion extends UpdateCompanion<ModifierGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> type;
  final Value<int> minSelected;
  final Value<int> maxSelected;
  final Value<int> rowid;
  const ModifierGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.minSelected = const Value.absent(),
    this.maxSelected = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModifierGroupsCompanion.insert({
    required String id,
    required String name,
    this.type = const Value.absent(),
    this.minSelected = const Value.absent(),
    this.maxSelected = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ModifierGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? minSelected,
    Expression<int>? maxSelected,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (minSelected != null) 'min_selected': minSelected,
      if (maxSelected != null) 'max_selected': maxSelected,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModifierGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? type,
    Value<int>? minSelected,
    Value<int>? maxSelected,
    Value<int>? rowid,
  }) {
    return ModifierGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      minSelected: minSelected ?? this.minSelected,
      maxSelected: maxSelected ?? this.maxSelected,
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
    if (minSelected.present) {
      map['min_selected'] = Variable<int>(minSelected.value);
    }
    if (maxSelected.present) {
      map['max_selected'] = Variable<int>(maxSelected.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModifierGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('minSelected: $minSelected, ')
          ..write('maxSelected: $maxSelected, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductModifierGroupsTable extends ProductModifierGroups
    with TableInfo<$ProductModifierGroupsTable, ProductModifierGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductModifierGroupsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _modifierGroupIdMeta = const VerificationMeta(
    'modifierGroupId',
  );
  @override
  late final GeneratedColumn<String> modifierGroupId = GeneratedColumn<String>(
    'modifier_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES modifier_groups (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [productId, modifierGroupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_modifier_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductModifierGroup> instance, {
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
    if (data.containsKey('modifier_group_id')) {
      context.handle(
        _modifierGroupIdMeta,
        modifierGroupId.isAcceptableOrUnknown(
          data['modifier_group_id']!,
          _modifierGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modifierGroupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId, modifierGroupId};
  @override
  ProductModifierGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductModifierGroup(
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      modifierGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modifier_group_id'],
      )!,
    );
  }

  @override
  $ProductModifierGroupsTable createAlias(String alias) {
    return $ProductModifierGroupsTable(attachedDatabase, alias);
  }
}

class ProductModifierGroup extends DataClass
    implements Insertable<ProductModifierGroup> {
  final String productId;
  final String modifierGroupId;
  const ProductModifierGroup({
    required this.productId,
    required this.modifierGroupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['modifier_group_id'] = Variable<String>(modifierGroupId);
    return map;
  }

  ProductModifierGroupsCompanion toCompanion(bool nullToAbsent) {
    return ProductModifierGroupsCompanion(
      productId: Value(productId),
      modifierGroupId: Value(modifierGroupId),
    );
  }

  factory ProductModifierGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductModifierGroup(
      productId: serializer.fromJson<String>(json['productId']),
      modifierGroupId: serializer.fromJson<String>(json['modifierGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'modifierGroupId': serializer.toJson<String>(modifierGroupId),
    };
  }

  ProductModifierGroup copyWith({String? productId, String? modifierGroupId}) =>
      ProductModifierGroup(
        productId: productId ?? this.productId,
        modifierGroupId: modifierGroupId ?? this.modifierGroupId,
      );
  ProductModifierGroup copyWithCompanion(ProductModifierGroupsCompanion data) {
    return ProductModifierGroup(
      productId: data.productId.present ? data.productId.value : this.productId,
      modifierGroupId: data.modifierGroupId.present
          ? data.modifierGroupId.value
          : this.modifierGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductModifierGroup(')
          ..write('productId: $productId, ')
          ..write('modifierGroupId: $modifierGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(productId, modifierGroupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductModifierGroup &&
          other.productId == this.productId &&
          other.modifierGroupId == this.modifierGroupId);
}

class ProductModifierGroupsCompanion
    extends UpdateCompanion<ProductModifierGroup> {
  final Value<String> productId;
  final Value<String> modifierGroupId;
  final Value<int> rowid;
  const ProductModifierGroupsCompanion({
    this.productId = const Value.absent(),
    this.modifierGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductModifierGroupsCompanion.insert({
    required String productId,
    required String modifierGroupId,
    this.rowid = const Value.absent(),
  }) : productId = Value(productId),
       modifierGroupId = Value(modifierGroupId);
  static Insertable<ProductModifierGroup> custom({
    Expression<String>? productId,
    Expression<String>? modifierGroupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (modifierGroupId != null) 'modifier_group_id': modifierGroupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductModifierGroupsCompanion copyWith({
    Value<String>? productId,
    Value<String>? modifierGroupId,
    Value<int>? rowid,
  }) {
    return ProductModifierGroupsCompanion(
      productId: productId ?? this.productId,
      modifierGroupId: modifierGroupId ?? this.modifierGroupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (modifierGroupId.present) {
      map['modifier_group_id'] = Variable<String>(modifierGroupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductModifierGroupsCompanion(')
          ..write('productId: $productId, ')
          ..write('modifierGroupId: $modifierGroupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModifierOptionsTable extends ModifierOptions
    with TableInfo<$ModifierOptionsTable, ModifierOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModifierOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifierGroupIdMeta = const VerificationMeta(
    'modifierGroupId',
  );
  @override
  late final GeneratedColumn<String> modifierGroupId = GeneratedColumn<String>(
    'modifier_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES modifier_groups (id)',
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
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, modifierGroupId, name, price];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'modifier_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModifierOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('modifier_group_id')) {
      context.handle(
        _modifierGroupIdMeta,
        modifierGroupId.isAcceptableOrUnknown(
          data['modifier_group_id']!,
          _modifierGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modifierGroupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModifierOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModifierOption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      modifierGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modifier_group_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
    );
  }

  @override
  $ModifierOptionsTable createAlias(String alias) {
    return $ModifierOptionsTable(attachedDatabase, alias);
  }
}

class ModifierOption extends DataClass implements Insertable<ModifierOption> {
  final String id;
  final String modifierGroupId;
  final String name;
  final double price;
  const ModifierOption({
    required this.id,
    required this.modifierGroupId,
    required this.name,
    required this.price,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['modifier_group_id'] = Variable<String>(modifierGroupId);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<double>(price);
    return map;
  }

  ModifierOptionsCompanion toCompanion(bool nullToAbsent) {
    return ModifierOptionsCompanion(
      id: Value(id),
      modifierGroupId: Value(modifierGroupId),
      name: Value(name),
      price: Value(price),
    );
  }

  factory ModifierOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModifierOption(
      id: serializer.fromJson<String>(json['id']),
      modifierGroupId: serializer.fromJson<String>(json['modifierGroupId']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<double>(json['price']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modifierGroupId': serializer.toJson<String>(modifierGroupId),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<double>(price),
    };
  }

  ModifierOption copyWith({
    String? id,
    String? modifierGroupId,
    String? name,
    double? price,
  }) => ModifierOption(
    id: id ?? this.id,
    modifierGroupId: modifierGroupId ?? this.modifierGroupId,
    name: name ?? this.name,
    price: price ?? this.price,
  );
  ModifierOption copyWithCompanion(ModifierOptionsCompanion data) {
    return ModifierOption(
      id: data.id.present ? data.id.value : this.id,
      modifierGroupId: data.modifierGroupId.present
          ? data.modifierGroupId.value
          : this.modifierGroupId,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModifierOption(')
          ..write('id: $id, ')
          ..write('modifierGroupId: $modifierGroupId, ')
          ..write('name: $name, ')
          ..write('price: $price')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, modifierGroupId, name, price);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModifierOption &&
          other.id == this.id &&
          other.modifierGroupId == this.modifierGroupId &&
          other.name == this.name &&
          other.price == this.price);
}

class ModifierOptionsCompanion extends UpdateCompanion<ModifierOption> {
  final Value<String> id;
  final Value<String> modifierGroupId;
  final Value<String> name;
  final Value<double> price;
  final Value<int> rowid;
  const ModifierOptionsCompanion({
    this.id = const Value.absent(),
    this.modifierGroupId = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModifierOptionsCompanion.insert({
    required String id,
    required String modifierGroupId,
    required String name,
    this.price = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       modifierGroupId = Value(modifierGroupId),
       name = Value(name);
  static Insertable<ModifierOption> custom({
    Expression<String>? id,
    Expression<String>? modifierGroupId,
    Expression<String>? name,
    Expression<double>? price,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modifierGroupId != null) 'modifier_group_id': modifierGroupId,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModifierOptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? modifierGroupId,
    Value<String>? name,
    Value<double>? price,
    Value<int>? rowid,
  }) {
    return ModifierOptionsCompanion(
      id: id ?? this.id,
      modifierGroupId: modifierGroupId ?? this.modifierGroupId,
      name: name ?? this.name,
      price: price ?? this.price,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modifierGroupId.present) {
      map['modifier_group_id'] = Variable<String>(modifierGroupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModifierOptionsCompanion(')
          ..write('id: $id, ')
          ..write('modifierGroupId: $modifierGroupId, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductPricesTable extends ProductPrices
    with TableInfo<$ProductPricesTable, ProductPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductPricesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _inventoryItemIdMeta = const VerificationMeta(
    'inventoryItemId',
  );
  @override
  late final GeneratedColumn<String> inventoryItemId = GeneratedColumn<String>(
    'inventory_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES inventories (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    inventoryItemId,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductPrice> instance, {
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
    if (data.containsKey('inventory_item_id')) {
      context.handle(
        _inventoryItemIdMeta,
        inventoryItemId.isAcceptableOrUnknown(
          data['inventory_item_id']!,
          _inventoryItemIdMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductPrice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      inventoryItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inventory_item_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $ProductPricesTable createAlias(String alias) {
    return $ProductPricesTable(attachedDatabase, alias);
  }
}

class ProductPrice extends DataClass implements Insertable<ProductPrice> {
  final String id;
  final String productId;
  final String? inventoryItemId;
  final double amount;
  const ProductPrice({
    required this.id,
    required this.productId,
    this.inventoryItemId,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    if (!nullToAbsent || inventoryItemId != null) {
      map['inventory_item_id'] = Variable<String>(inventoryItemId);
    }
    map['amount'] = Variable<double>(amount);
    return map;
  }

  ProductPricesCompanion toCompanion(bool nullToAbsent) {
    return ProductPricesCompanion(
      id: Value(id),
      productId: Value(productId),
      inventoryItemId: inventoryItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(inventoryItemId),
      amount: Value(amount),
    );
  }

  factory ProductPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductPrice(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      inventoryItemId: serializer.fromJson<String?>(json['inventoryItemId']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'inventoryItemId': serializer.toJson<String?>(inventoryItemId),
      'amount': serializer.toJson<double>(amount),
    };
  }

  ProductPrice copyWith({
    String? id,
    String? productId,
    Value<String?> inventoryItemId = const Value.absent(),
    double? amount,
  }) => ProductPrice(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    inventoryItemId: inventoryItemId.present
        ? inventoryItemId.value
        : this.inventoryItemId,
    amount: amount ?? this.amount,
  );
  ProductPrice copyWithCompanion(ProductPricesCompanion data) {
    return ProductPrice(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      inventoryItemId: data.inventoryItemId.present
          ? data.inventoryItemId.value
          : this.inventoryItemId,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductPrice(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('inventoryItemId: $inventoryItemId, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, inventoryItemId, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductPrice &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.inventoryItemId == this.inventoryItemId &&
          other.amount == this.amount);
}

class ProductPricesCompanion extends UpdateCompanion<ProductPrice> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String?> inventoryItemId;
  final Value<double> amount;
  final Value<int> rowid;
  const ProductPricesCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.inventoryItemId = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductPricesCompanion.insert({
    required String id,
    required String productId,
    this.inventoryItemId = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId);
  static Insertable<ProductPrice> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? inventoryItemId,
    Expression<double>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (inventoryItemId != null) 'inventory_item_id': inventoryItemId,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductPricesCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String?>? inventoryItemId,
    Value<double>? amount,
    Value<int>? rowid,
  }) {
    return ProductPricesCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      amount: amount ?? this.amount,
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
    if (inventoryItemId.present) {
      map['inventory_item_id'] = Variable<String>(inventoryItemId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductPricesCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('inventoryItemId: $inventoryItemId, ')
          ..write('amount: $amount, ')
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
    requiredDuringInsert: false,
    defaultValue: const Constant('pos'),
  );
  static const VerificationMeta _transactionNumberMeta = const VerificationMeta(
    'transactionNumber',
  );
  @override
  late final GeneratedColumn<String> transactionNumber =
      GeneratedColumn<String>(
        'transaction_number',
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
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<String> discountType = GeneratedColumn<String>(
    'discount_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountValueMeta = const VerificationMeta(
    'discountValue',
  );
  @override
  late final GeneratedColumn<double> discountValue = GeneratedColumn<double>(
    'discount_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promoNameMeta = const VerificationMeta(
    'promoName',
  );
  @override
  late final GeneratedColumn<String> promoName = GeneratedColumn<String>(
    'promo_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _shippingFeeMeta = const VerificationMeta(
    'shippingFee',
  );
  @override
  late final GeneratedColumn<double> shippingFee = GeneratedColumn<double>(
    'shipping_fee',
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    outletId,
    shiftId,
    customerId,
    channel,
    transactionNumber,
    subtotal,
    discountAmount,
    discountType,
    discountValue,
    promoName,
    taxAmount,
    serviceChargeAmount,
    shippingFee,
    total,
    paymentStatus,
    status,
    notes,
    isOffline,
    offlineId,
    dueDate,
    createdAt,
    updatedAt,
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
    }
    if (data.containsKey('transaction_number')) {
      context.handle(
        _transactionNumberMeta,
        transactionNumber.isAcceptableOrUnknown(
          data['transaction_number']!,
          _transactionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionNumberMeta);
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
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('discount_value')) {
      context.handle(
        _discountValueMeta,
        discountValue.isAcceptableOrUnknown(
          data['discount_value']!,
          _discountValueMeta,
        ),
      );
    }
    if (data.containsKey('promo_name')) {
      context.handle(
        _promoNameMeta,
        promoName.isAcceptableOrUnknown(data['promo_name']!, _promoNameMeta),
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
    if (data.containsKey('shipping_fee')) {
      context.handle(
        _shippingFeeMeta,
        shippingFee.isAcceptableOrUnknown(
          data['shipping_fee']!,
          _shippingFeeMeta,
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
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
      transactionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_number'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_type'],
      ),
      discountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_value'],
      ),
      promoName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}promo_name'],
      ),
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      )!,
      serviceChargeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}service_charge_amount'],
      )!,
      shippingFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shipping_fee'],
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
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_offline'],
      )!,
      offlineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offline_id'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
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
  final String transactionNumber;
  final double subtotal;
  final double discountAmount;
  final String? discountType;
  final double? discountValue;
  final String? promoName;
  final double taxAmount;
  final double serviceChargeAmount;
  final double shippingFee;
  final double total;
  final String paymentStatus;
  final String status;
  final String? notes;
  final bool isOffline;
  final String? offlineId;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Transaction({
    required this.id,
    required this.outletId,
    this.shiftId,
    this.customerId,
    required this.channel,
    required this.transactionNumber,
    required this.subtotal,
    required this.discountAmount,
    this.discountType,
    this.discountValue,
    this.promoName,
    required this.taxAmount,
    required this.serviceChargeAmount,
    required this.shippingFee,
    required this.total,
    required this.paymentStatus,
    required this.status,
    this.notes,
    required this.isOffline,
    this.offlineId,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
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
    map['transaction_number'] = Variable<String>(transactionNumber);
    map['subtotal'] = Variable<double>(subtotal);
    map['discount_amount'] = Variable<double>(discountAmount);
    if (!nullToAbsent || discountType != null) {
      map['discount_type'] = Variable<String>(discountType);
    }
    if (!nullToAbsent || discountValue != null) {
      map['discount_value'] = Variable<double>(discountValue);
    }
    if (!nullToAbsent || promoName != null) {
      map['promo_name'] = Variable<String>(promoName);
    }
    map['tax_amount'] = Variable<double>(taxAmount);
    map['service_charge_amount'] = Variable<double>(serviceChargeAmount);
    map['shipping_fee'] = Variable<double>(shippingFee);
    map['total'] = Variable<double>(total);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_offline'] = Variable<bool>(isOffline);
    if (!nullToAbsent || offlineId != null) {
      map['offline_id'] = Variable<String>(offlineId);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
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
      transactionNumber: Value(transactionNumber),
      subtotal: Value(subtotal),
      discountAmount: Value(discountAmount),
      discountType: discountType == null && nullToAbsent
          ? const Value.absent()
          : Value(discountType),
      discountValue: discountValue == null && nullToAbsent
          ? const Value.absent()
          : Value(discountValue),
      promoName: promoName == null && nullToAbsent
          ? const Value.absent()
          : Value(promoName),
      taxAmount: Value(taxAmount),
      serviceChargeAmount: Value(serviceChargeAmount),
      shippingFee: Value(shippingFee),
      total: Value(total),
      paymentStatus: Value(paymentStatus),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isOffline: Value(isOffline),
      offlineId: offlineId == null && nullToAbsent
          ? const Value.absent()
          : Value(offlineId),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
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
      transactionNumber: serializer.fromJson<String>(json['transactionNumber']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      discountType: serializer.fromJson<String?>(json['discountType']),
      discountValue: serializer.fromJson<double?>(json['discountValue']),
      promoName: serializer.fromJson<String?>(json['promoName']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      serviceChargeAmount: serializer.fromJson<double>(
        json['serviceChargeAmount'],
      ),
      shippingFee: serializer.fromJson<double>(json['shippingFee']),
      total: serializer.fromJson<double>(json['total']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      isOffline: serializer.fromJson<bool>(json['isOffline']),
      offlineId: serializer.fromJson<String?>(json['offlineId']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
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
      'transactionNumber': serializer.toJson<String>(transactionNumber),
      'subtotal': serializer.toJson<double>(subtotal),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'discountType': serializer.toJson<String?>(discountType),
      'discountValue': serializer.toJson<double?>(discountValue),
      'promoName': serializer.toJson<String?>(promoName),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'serviceChargeAmount': serializer.toJson<double>(serviceChargeAmount),
      'shippingFee': serializer.toJson<double>(shippingFee),
      'total': serializer.toJson<double>(total),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'isOffline': serializer.toJson<bool>(isOffline),
      'offlineId': serializer.toJson<String?>(offlineId),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Transaction copyWith({
    String? id,
    String? outletId,
    Value<String?> shiftId = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? channel,
    String? transactionNumber,
    double? subtotal,
    double? discountAmount,
    Value<String?> discountType = const Value.absent(),
    Value<double?> discountValue = const Value.absent(),
    Value<String?> promoName = const Value.absent(),
    double? taxAmount,
    double? serviceChargeAmount,
    double? shippingFee,
    double? total,
    String? paymentStatus,
    String? status,
    Value<String?> notes = const Value.absent(),
    bool? isOffline,
    Value<String?> offlineId = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    outletId: outletId ?? this.outletId,
    shiftId: shiftId.present ? shiftId.value : this.shiftId,
    customerId: customerId.present ? customerId.value : this.customerId,
    channel: channel ?? this.channel,
    transactionNumber: transactionNumber ?? this.transactionNumber,
    subtotal: subtotal ?? this.subtotal,
    discountAmount: discountAmount ?? this.discountAmount,
    discountType: discountType.present ? discountType.value : this.discountType,
    discountValue: discountValue.present
        ? discountValue.value
        : this.discountValue,
    promoName: promoName.present ? promoName.value : this.promoName,
    taxAmount: taxAmount ?? this.taxAmount,
    serviceChargeAmount: serviceChargeAmount ?? this.serviceChargeAmount,
    shippingFee: shippingFee ?? this.shippingFee,
    total: total ?? this.total,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    isOffline: isOffline ?? this.isOffline,
    offlineId: offlineId.present ? offlineId.value : this.offlineId,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
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
      transactionNumber: data.transactionNumber.present
          ? data.transactionNumber.value
          : this.transactionNumber,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
      promoName: data.promoName.present ? data.promoName.value : this.promoName,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      serviceChargeAmount: data.serviceChargeAmount.present
          ? data.serviceChargeAmount.value
          : this.serviceChargeAmount,
      shippingFee: data.shippingFee.present
          ? data.shippingFee.value
          : this.shippingFee,
      total: data.total.present ? data.total.value : this.total,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      isOffline: data.isOffline.present ? data.isOffline.value : this.isOffline,
      offlineId: data.offlineId.present ? data.offlineId.value : this.offlineId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
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
          ..write('transactionNumber: $transactionNumber, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('promoName: $promoName, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('serviceChargeAmount: $serviceChargeAmount, ')
          ..write('shippingFee: $shippingFee, ')
          ..write('total: $total, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('isOffline: $isOffline, ')
          ..write('offlineId: $offlineId, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    outletId,
    shiftId,
    customerId,
    channel,
    transactionNumber,
    subtotal,
    discountAmount,
    discountType,
    discountValue,
    promoName,
    taxAmount,
    serviceChargeAmount,
    shippingFee,
    total,
    paymentStatus,
    status,
    notes,
    isOffline,
    offlineId,
    dueDate,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.outletId == this.outletId &&
          other.shiftId == this.shiftId &&
          other.customerId == this.customerId &&
          other.channel == this.channel &&
          other.transactionNumber == this.transactionNumber &&
          other.subtotal == this.subtotal &&
          other.discountAmount == this.discountAmount &&
          other.discountType == this.discountType &&
          other.discountValue == this.discountValue &&
          other.promoName == this.promoName &&
          other.taxAmount == this.taxAmount &&
          other.serviceChargeAmount == this.serviceChargeAmount &&
          other.shippingFee == this.shippingFee &&
          other.total == this.total &&
          other.paymentStatus == this.paymentStatus &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.isOffline == this.isOffline &&
          other.offlineId == this.offlineId &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> outletId;
  final Value<String?> shiftId;
  final Value<String?> customerId;
  final Value<String> channel;
  final Value<String> transactionNumber;
  final Value<double> subtotal;
  final Value<double> discountAmount;
  final Value<String?> discountType;
  final Value<double?> discountValue;
  final Value<String?> promoName;
  final Value<double> taxAmount;
  final Value<double> serviceChargeAmount;
  final Value<double> shippingFee;
  final Value<double> total;
  final Value<String> paymentStatus;
  final Value<String> status;
  final Value<String?> notes;
  final Value<bool> isOffline;
  final Value<String?> offlineId;
  final Value<DateTime?> dueDate;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.outletId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.channel = const Value.absent(),
    this.transactionNumber = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.promoName = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.serviceChargeAmount = const Value.absent(),
    this.shippingFee = const Value.absent(),
    this.total = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.isOffline = const Value.absent(),
    this.offlineId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String outletId,
    this.shiftId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.channel = const Value.absent(),
    required String transactionNumber,
    required double subtotal,
    this.discountAmount = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.promoName = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.serviceChargeAmount = const Value.absent(),
    this.shippingFee = const Value.absent(),
    required double total,
    required String paymentStatus,
    required String status,
    this.notes = const Value.absent(),
    this.isOffline = const Value.absent(),
    this.offlineId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       outletId = Value(outletId),
       transactionNumber = Value(transactionNumber),
       subtotal = Value(subtotal),
       total = Value(total),
       paymentStatus = Value(paymentStatus),
       status = Value(status);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? outletId,
    Expression<String>? shiftId,
    Expression<String>? customerId,
    Expression<String>? channel,
    Expression<String>? transactionNumber,
    Expression<double>? subtotal,
    Expression<double>? discountAmount,
    Expression<String>? discountType,
    Expression<double>? discountValue,
    Expression<String>? promoName,
    Expression<double>? taxAmount,
    Expression<double>? serviceChargeAmount,
    Expression<double>? shippingFee,
    Expression<double>? total,
    Expression<String>? paymentStatus,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<bool>? isOffline,
    Expression<String>? offlineId,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (outletId != null) 'outlet_id': outletId,
      if (shiftId != null) 'shift_id': shiftId,
      if (customerId != null) 'customer_id': customerId,
      if (channel != null) 'channel': channel,
      if (transactionNumber != null) 'transaction_number': transactionNumber,
      if (subtotal != null) 'subtotal': subtotal,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (discountType != null) 'discount_type': discountType,
      if (discountValue != null) 'discount_value': discountValue,
      if (promoName != null) 'promo_name': promoName,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (serviceChargeAmount != null)
        'service_charge_amount': serviceChargeAmount,
      if (shippingFee != null) 'shipping_fee': shippingFee,
      if (total != null) 'total': total,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (isOffline != null) 'is_offline': isOffline,
      if (offlineId != null) 'offline_id': offlineId,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? outletId,
    Value<String?>? shiftId,
    Value<String?>? customerId,
    Value<String>? channel,
    Value<String>? transactionNumber,
    Value<double>? subtotal,
    Value<double>? discountAmount,
    Value<String?>? discountType,
    Value<double?>? discountValue,
    Value<String?>? promoName,
    Value<double>? taxAmount,
    Value<double>? serviceChargeAmount,
    Value<double>? shippingFee,
    Value<double>? total,
    Value<String>? paymentStatus,
    Value<String>? status,
    Value<String?>? notes,
    Value<bool>? isOffline,
    Value<String?>? offlineId,
    Value<DateTime?>? dueDate,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      outletId: outletId ?? this.outletId,
      shiftId: shiftId ?? this.shiftId,
      customerId: customerId ?? this.customerId,
      channel: channel ?? this.channel,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      promoName: promoName ?? this.promoName,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceChargeAmount: serviceChargeAmount ?? this.serviceChargeAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      total: total ?? this.total,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isOffline: isOffline ?? this.isOffline,
      offlineId: offlineId ?? this.offlineId,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (transactionNumber.present) {
      map['transaction_number'] = Variable<String>(transactionNumber.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<String>(discountType.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<double>(discountValue.value);
    }
    if (promoName.present) {
      map['promo_name'] = Variable<String>(promoName.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (serviceChargeAmount.present) {
      map['service_charge_amount'] = Variable<double>(
        serviceChargeAmount.value,
      );
    }
    if (shippingFee.present) {
      map['shipping_fee'] = Variable<double>(shippingFee.value);
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
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
          ..write('transactionNumber: $transactionNumber, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('promoName: $promoName, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('serviceChargeAmount: $serviceChargeAmount, ')
          ..write('shippingFee: $shippingFee, ')
          ..write('total: $total, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('isOffline: $isOffline, ')
          ..write('offlineId: $offlineId, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inventoryItemIdMeta = const VerificationMeta(
    'inventoryItemId',
  );
  @override
  late final GeneratedColumn<String> inventoryItemId = GeneratedColumn<String>(
    'inventory_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _variantGroupOptionIdMeta =
      const VerificationMeta('variantGroupOptionId');
  @override
  late final GeneratedColumn<String> variantGroupOptionId =
      GeneratedColumn<String>(
        'variant_group_option_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
  static const VerificationMeta _promoNameMeta = const VerificationMeta(
    'promoName',
  );
  @override
  late final GeneratedColumn<String> promoName = GeneratedColumn<String>(
    'promo_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    transactionId,
    productId,
    inventoryItemId,
    variantGroupOptionId,
    productName,
    price,
    qty,
    discountAmount,
    promoName,
    subtotal,
    notes,
    createdAt,
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
    }
    if (data.containsKey('inventory_item_id')) {
      context.handle(
        _inventoryItemIdMeta,
        inventoryItemId.isAcceptableOrUnknown(
          data['inventory_item_id']!,
          _inventoryItemIdMeta,
        ),
      );
    }
    if (data.containsKey('variant_group_option_id')) {
      context.handle(
        _variantGroupOptionIdMeta,
        variantGroupOptionId.isAcceptableOrUnknown(
          data['variant_group_option_id']!,
          _variantGroupOptionIdMeta,
        ),
      );
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
    if (data.containsKey('promo_name')) {
      context.handle(
        _promoNameMeta,
        promoName.isAcceptableOrUnknown(data['promo_name']!, _promoNameMeta),
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
      ),
      inventoryItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inventory_item_id'],
      ),
      variantGroupOptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_group_option_id'],
      ),
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
      promoName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}promo_name'],
      ),
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
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
  final String? productId;
  final String? inventoryItemId;
  final String? variantGroupOptionId;
  final String productName;
  final double price;
  final double qty;
  final double discountAmount;
  final String? promoName;
  final double subtotal;
  final String? notes;
  final DateTime createdAt;
  const TransactionItem({
    required this.id,
    required this.transactionId,
    this.productId,
    this.inventoryItemId,
    this.variantGroupOptionId,
    required this.productName,
    required this.price,
    required this.qty,
    required this.discountAmount,
    this.promoName,
    required this.subtotal,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || inventoryItemId != null) {
      map['inventory_item_id'] = Variable<String>(inventoryItemId);
    }
    if (!nullToAbsent || variantGroupOptionId != null) {
      map['variant_group_option_id'] = Variable<String>(variantGroupOptionId);
    }
    map['product_name'] = Variable<String>(productName);
    map['price'] = Variable<double>(price);
    map['qty'] = Variable<double>(qty);
    map['discount_amount'] = Variable<double>(discountAmount);
    if (!nullToAbsent || promoName != null) {
      map['promo_name'] = Variable<String>(promoName);
    }
    map['subtotal'] = Variable<double>(subtotal);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionItemsCompanion toCompanion(bool nullToAbsent) {
    return TransactionItemsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      inventoryItemId: inventoryItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(inventoryItemId),
      variantGroupOptionId: variantGroupOptionId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantGroupOptionId),
      productName: Value(productName),
      price: Value(price),
      qty: Value(qty),
      discountAmount: Value(discountAmount),
      promoName: promoName == null && nullToAbsent
          ? const Value.absent()
          : Value(promoName),
      subtotal: Value(subtotal),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
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
      productId: serializer.fromJson<String?>(json['productId']),
      inventoryItemId: serializer.fromJson<String?>(json['inventoryItemId']),
      variantGroupOptionId: serializer.fromJson<String?>(
        json['variantGroupOptionId'],
      ),
      productName: serializer.fromJson<String>(json['productName']),
      price: serializer.fromJson<double>(json['price']),
      qty: serializer.fromJson<double>(json['qty']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      promoName: serializer.fromJson<String?>(json['promoName']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'productId': serializer.toJson<String?>(productId),
      'inventoryItemId': serializer.toJson<String?>(inventoryItemId),
      'variantGroupOptionId': serializer.toJson<String?>(variantGroupOptionId),
      'productName': serializer.toJson<String>(productName),
      'price': serializer.toJson<double>(price),
      'qty': serializer.toJson<double>(qty),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'promoName': serializer.toJson<String?>(promoName),
      'subtotal': serializer.toJson<double>(subtotal),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionItem copyWith({
    String? id,
    String? transactionId,
    Value<String?> productId = const Value.absent(),
    Value<String?> inventoryItemId = const Value.absent(),
    Value<String?> variantGroupOptionId = const Value.absent(),
    String? productName,
    double? price,
    double? qty,
    double? discountAmount,
    Value<String?> promoName = const Value.absent(),
    double? subtotal,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => TransactionItem(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    productId: productId.present ? productId.value : this.productId,
    inventoryItemId: inventoryItemId.present
        ? inventoryItemId.value
        : this.inventoryItemId,
    variantGroupOptionId: variantGroupOptionId.present
        ? variantGroupOptionId.value
        : this.variantGroupOptionId,
    productName: productName ?? this.productName,
    price: price ?? this.price,
    qty: qty ?? this.qty,
    discountAmount: discountAmount ?? this.discountAmount,
    promoName: promoName.present ? promoName.value : this.promoName,
    subtotal: subtotal ?? this.subtotal,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  TransactionItem copyWithCompanion(TransactionItemsCompanion data) {
    return TransactionItem(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      productId: data.productId.present ? data.productId.value : this.productId,
      inventoryItemId: data.inventoryItemId.present
          ? data.inventoryItemId.value
          : this.inventoryItemId,
      variantGroupOptionId: data.variantGroupOptionId.present
          ? data.variantGroupOptionId.value
          : this.variantGroupOptionId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      price: data.price.present ? data.price.value : this.price,
      qty: data.qty.present ? data.qty.value : this.qty,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      promoName: data.promoName.present ? data.promoName.value : this.promoName,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItem(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('inventoryItemId: $inventoryItemId, ')
          ..write('variantGroupOptionId: $variantGroupOptionId, ')
          ..write('productName: $productName, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('promoName: $promoName, ')
          ..write('subtotal: $subtotal, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    productId,
    inventoryItemId,
    variantGroupOptionId,
    productName,
    price,
    qty,
    discountAmount,
    promoName,
    subtotal,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItem &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.productId == this.productId &&
          other.inventoryItemId == this.inventoryItemId &&
          other.variantGroupOptionId == this.variantGroupOptionId &&
          other.productName == this.productName &&
          other.price == this.price &&
          other.qty == this.qty &&
          other.discountAmount == this.discountAmount &&
          other.promoName == this.promoName &&
          other.subtotal == this.subtotal &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class TransactionItemsCompanion extends UpdateCompanion<TransactionItem> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String?> productId;
  final Value<String?> inventoryItemId;
  final Value<String?> variantGroupOptionId;
  final Value<String> productName;
  final Value<double> price;
  final Value<double> qty;
  final Value<double> discountAmount;
  final Value<String?> promoName;
  final Value<double> subtotal;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransactionItemsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.productId = const Value.absent(),
    this.inventoryItemId = const Value.absent(),
    this.variantGroupOptionId = const Value.absent(),
    this.productName = const Value.absent(),
    this.price = const Value.absent(),
    this.qty = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.promoName = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionItemsCompanion.insert({
    required String id,
    required String transactionId,
    this.productId = const Value.absent(),
    this.inventoryItemId = const Value.absent(),
    this.variantGroupOptionId = const Value.absent(),
    required String productName,
    required double price,
    required double qty,
    this.discountAmount = const Value.absent(),
    this.promoName = const Value.absent(),
    required double subtotal,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       productName = Value(productName),
       price = Value(price),
       qty = Value(qty),
       subtotal = Value(subtotal);
  static Insertable<TransactionItem> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? productId,
    Expression<String>? inventoryItemId,
    Expression<String>? variantGroupOptionId,
    Expression<String>? productName,
    Expression<double>? price,
    Expression<double>? qty,
    Expression<double>? discountAmount,
    Expression<String>? promoName,
    Expression<double>? subtotal,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (productId != null) 'product_id': productId,
      if (inventoryItemId != null) 'inventory_item_id': inventoryItemId,
      if (variantGroupOptionId != null)
        'variant_group_option_id': variantGroupOptionId,
      if (productName != null) 'product_name': productName,
      if (price != null) 'price': price,
      if (qty != null) 'qty': qty,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (promoName != null) 'promo_name': promoName,
      if (subtotal != null) 'subtotal': subtotal,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String?>? productId,
    Value<String?>? inventoryItemId,
    Value<String?>? variantGroupOptionId,
    Value<String>? productName,
    Value<double>? price,
    Value<double>? qty,
    Value<double>? discountAmount,
    Value<String?>? promoName,
    Value<double>? subtotal,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TransactionItemsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      variantGroupOptionId: variantGroupOptionId ?? this.variantGroupOptionId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      discountAmount: discountAmount ?? this.discountAmount,
      promoName: promoName ?? this.promoName,
      subtotal: subtotal ?? this.subtotal,
      notes: notes ?? this.notes,
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
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (inventoryItemId.present) {
      map['inventory_item_id'] = Variable<String>(inventoryItemId.value);
    }
    if (variantGroupOptionId.present) {
      map['variant_group_option_id'] = Variable<String>(
        variantGroupOptionId.value,
      );
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
    if (promoName.present) {
      map['promo_name'] = Variable<String>(promoName.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('TransactionItemsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('inventoryItemId: $inventoryItemId, ')
          ..write('variantGroupOptionId: $variantGroupOptionId, ')
          ..write('productName: $productName, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('promoName: $promoName, ')
          ..write('subtotal: $subtotal, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
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
  static const VerificationMeta _modifierOptionIdMeta = const VerificationMeta(
    'modifierOptionId',
  );
  @override
  late final GeneratedColumn<String> modifierOptionId = GeneratedColumn<String>(
    'modifier_option_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionItemId,
    modifierOptionId,
    modifierName,
    price,
    qty,
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
    if (data.containsKey('modifier_option_id')) {
      context.handle(
        _modifierOptionIdMeta,
        modifierOptionId.isAcceptableOrUnknown(
          data['modifier_option_id']!,
          _modifierOptionIdMeta,
        ),
      );
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
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
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
      modifierOptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modifier_option_id'],
      ),
      modifierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modifier_name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qty'],
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
  final String? modifierOptionId;
  final String modifierName;
  final double price;
  final double qty;
  const TransactionItemModifier({
    required this.id,
    required this.transactionItemId,
    this.modifierOptionId,
    required this.modifierName,
    required this.price,
    required this.qty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_item_id'] = Variable<String>(transactionItemId);
    if (!nullToAbsent || modifierOptionId != null) {
      map['modifier_option_id'] = Variable<String>(modifierOptionId);
    }
    map['modifier_name'] = Variable<String>(modifierName);
    map['price'] = Variable<double>(price);
    map['qty'] = Variable<double>(qty);
    return map;
  }

  TransactionItemModifiersCompanion toCompanion(bool nullToAbsent) {
    return TransactionItemModifiersCompanion(
      id: Value(id),
      transactionItemId: Value(transactionItemId),
      modifierOptionId: modifierOptionId == null && nullToAbsent
          ? const Value.absent()
          : Value(modifierOptionId),
      modifierName: Value(modifierName),
      price: Value(price),
      qty: Value(qty),
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
      modifierOptionId: serializer.fromJson<String?>(json['modifierOptionId']),
      modifierName: serializer.fromJson<String>(json['modifierName']),
      price: serializer.fromJson<double>(json['price']),
      qty: serializer.fromJson<double>(json['qty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionItemId': serializer.toJson<String>(transactionItemId),
      'modifierOptionId': serializer.toJson<String?>(modifierOptionId),
      'modifierName': serializer.toJson<String>(modifierName),
      'price': serializer.toJson<double>(price),
      'qty': serializer.toJson<double>(qty),
    };
  }

  TransactionItemModifier copyWith({
    String? id,
    String? transactionItemId,
    Value<String?> modifierOptionId = const Value.absent(),
    String? modifierName,
    double? price,
    double? qty,
  }) => TransactionItemModifier(
    id: id ?? this.id,
    transactionItemId: transactionItemId ?? this.transactionItemId,
    modifierOptionId: modifierOptionId.present
        ? modifierOptionId.value
        : this.modifierOptionId,
    modifierName: modifierName ?? this.modifierName,
    price: price ?? this.price,
    qty: qty ?? this.qty,
  );
  TransactionItemModifier copyWithCompanion(
    TransactionItemModifiersCompanion data,
  ) {
    return TransactionItemModifier(
      id: data.id.present ? data.id.value : this.id,
      transactionItemId: data.transactionItemId.present
          ? data.transactionItemId.value
          : this.transactionItemId,
      modifierOptionId: data.modifierOptionId.present
          ? data.modifierOptionId.value
          : this.modifierOptionId,
      modifierName: data.modifierName.present
          ? data.modifierName.value
          : this.modifierName,
      price: data.price.present ? data.price.value : this.price,
      qty: data.qty.present ? data.qty.value : this.qty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemModifier(')
          ..write('id: $id, ')
          ..write('transactionItemId: $transactionItemId, ')
          ..write('modifierOptionId: $modifierOptionId, ')
          ..write('modifierName: $modifierName, ')
          ..write('price: $price, ')
          ..write('qty: $qty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionItemId,
    modifierOptionId,
    modifierName,
    price,
    qty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItemModifier &&
          other.id == this.id &&
          other.transactionItemId == this.transactionItemId &&
          other.modifierOptionId == this.modifierOptionId &&
          other.modifierName == this.modifierName &&
          other.price == this.price &&
          other.qty == this.qty);
}

class TransactionItemModifiersCompanion
    extends UpdateCompanion<TransactionItemModifier> {
  final Value<String> id;
  final Value<String> transactionItemId;
  final Value<String?> modifierOptionId;
  final Value<String> modifierName;
  final Value<double> price;
  final Value<double> qty;
  final Value<int> rowid;
  const TransactionItemModifiersCompanion({
    this.id = const Value.absent(),
    this.transactionItemId = const Value.absent(),
    this.modifierOptionId = const Value.absent(),
    this.modifierName = const Value.absent(),
    this.price = const Value.absent(),
    this.qty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionItemModifiersCompanion.insert({
    required String id,
    required String transactionItemId,
    this.modifierOptionId = const Value.absent(),
    required String modifierName,
    this.price = const Value.absent(),
    this.qty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionItemId = Value(transactionItemId),
       modifierName = Value(modifierName);
  static Insertable<TransactionItemModifier> custom({
    Expression<String>? id,
    Expression<String>? transactionItemId,
    Expression<String>? modifierOptionId,
    Expression<String>? modifierName,
    Expression<double>? price,
    Expression<double>? qty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionItemId != null) 'transaction_item_id': transactionItemId,
      if (modifierOptionId != null) 'modifier_option_id': modifierOptionId,
      if (modifierName != null) 'modifier_name': modifierName,
      if (price != null) 'price': price,
      if (qty != null) 'qty': qty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionItemModifiersCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionItemId,
    Value<String?>? modifierOptionId,
    Value<String>? modifierName,
    Value<double>? price,
    Value<double>? qty,
    Value<int>? rowid,
  }) {
    return TransactionItemModifiersCompanion(
      id: id ?? this.id,
      transactionItemId: transactionItemId ?? this.transactionItemId,
      modifierOptionId: modifierOptionId ?? this.modifierOptionId,
      modifierName: modifierName ?? this.modifierName,
      price: price ?? this.price,
      qty: qty ?? this.qty,
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
    if (modifierOptionId.present) {
      map['modifier_option_id'] = Variable<String>(modifierOptionId.value);
    }
    if (modifierName.present) {
      map['modifier_name'] = Variable<String>(modifierName.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
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
          ..write('modifierOptionId: $modifierOptionId, ')
          ..write('modifierName: $modifierName, ')
          ..write('price: $price, ')
          ..write('qty: $qty, ')
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _paymentReferenceMeta = const VerificationMeta(
    'paymentReference',
  );
  @override
  late final GeneratedColumn<String> paymentReference = GeneratedColumn<String>(
    'payment_reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    paymentReference,
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
    if (data.containsKey('payment_reference')) {
      context.handle(
        _paymentReferenceMeta,
        paymentReference.isAcceptableOrUnknown(
          data['payment_reference']!,
          _paymentReferenceMeta,
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
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      changeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}change_amount'],
      )!,
      paymentReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_reference'],
      ),
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
  final String? paymentMethodId;
  final double amount;
  final double changeAmount;
  final String? paymentReference;
  final DateTime paidAt;
  const TransactionPayment({
    required this.id,
    required this.transactionId,
    this.paymentMethodId,
    required this.amount,
    required this.changeAmount,
    this.paymentReference,
    required this.paidAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    if (!nullToAbsent || paymentMethodId != null) {
      map['payment_method_id'] = Variable<String>(paymentMethodId);
    }
    map['amount'] = Variable<double>(amount);
    map['change_amount'] = Variable<double>(changeAmount);
    if (!nullToAbsent || paymentReference != null) {
      map['payment_reference'] = Variable<String>(paymentReference);
    }
    map['paid_at'] = Variable<DateTime>(paidAt);
    return map;
  }

  TransactionPaymentsCompanion toCompanion(bool nullToAbsent) {
    return TransactionPaymentsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      paymentMethodId: paymentMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethodId),
      amount: Value(amount),
      changeAmount: Value(changeAmount),
      paymentReference: paymentReference == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentReference),
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
      paymentMethodId: serializer.fromJson<String?>(json['paymentMethodId']),
      amount: serializer.fromJson<double>(json['amount']),
      changeAmount: serializer.fromJson<double>(json['changeAmount']),
      paymentReference: serializer.fromJson<String?>(json['paymentReference']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'paymentMethodId': serializer.toJson<String?>(paymentMethodId),
      'amount': serializer.toJson<double>(amount),
      'changeAmount': serializer.toJson<double>(changeAmount),
      'paymentReference': serializer.toJson<String?>(paymentReference),
      'paidAt': serializer.toJson<DateTime>(paidAt),
    };
  }

  TransactionPayment copyWith({
    String? id,
    String? transactionId,
    Value<String?> paymentMethodId = const Value.absent(),
    double? amount,
    double? changeAmount,
    Value<String?> paymentReference = const Value.absent(),
    DateTime? paidAt,
  }) => TransactionPayment(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    paymentMethodId: paymentMethodId.present
        ? paymentMethodId.value
        : this.paymentMethodId,
    amount: amount ?? this.amount,
    changeAmount: changeAmount ?? this.changeAmount,
    paymentReference: paymentReference.present
        ? paymentReference.value
        : this.paymentReference,
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
      paymentReference: data.paymentReference.present
          ? data.paymentReference.value
          : this.paymentReference,
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
          ..write('paymentReference: $paymentReference, ')
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
    paymentReference,
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
          other.paymentReference == this.paymentReference &&
          other.paidAt == this.paidAt);
}

class TransactionPaymentsCompanion extends UpdateCompanion<TransactionPayment> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String?> paymentMethodId;
  final Value<double> amount;
  final Value<double> changeAmount;
  final Value<String?> paymentReference;
  final Value<DateTime> paidAt;
  final Value<int> rowid;
  const TransactionPaymentsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.amount = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.paymentReference = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionPaymentsCompanion.insert({
    required String id,
    required String transactionId,
    this.paymentMethodId = const Value.absent(),
    required double amount,
    this.changeAmount = const Value.absent(),
    this.paymentReference = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       amount = Value(amount);
  static Insertable<TransactionPayment> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? paymentMethodId,
    Expression<double>? amount,
    Expression<double>? changeAmount,
    Expression<String>? paymentReference,
    Expression<DateTime>? paidAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (amount != null) 'amount': amount,
      if (changeAmount != null) 'change_amount': changeAmount,
      if (paymentReference != null) 'payment_reference': paymentReference,
      if (paidAt != null) 'paid_at': paidAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String?>? paymentMethodId,
    Value<double>? amount,
    Value<double>? changeAmount,
    Value<String?>? paymentReference,
    Value<DateTime>? paidAt,
    Value<int>? rowid,
  }) {
    return TransactionPaymentsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      amount: amount ?? this.amount,
      changeAmount: changeAmount ?? this.changeAmount,
      paymentReference: paymentReference ?? this.paymentReference,
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
    if (paymentReference.present) {
      map['payment_reference'] = Variable<String>(paymentReference.value);
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
          ..write('paymentReference: $paymentReference, ')
          ..write('paidAt: $paidAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromosTable extends Promos with TableInfo<$PromosTable, Promo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promoTypeMeta = const VerificationMeta(
    'promoType',
  );
  @override
  late final GeneratedColumn<String> promoType = GeneratedColumn<String>(
    'promo_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountValueMeta = const VerificationMeta(
    'discountValue',
  );
  @override
  late final GeneratedColumn<double> discountValue = GeneratedColumn<double>(
    'discount_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxDiscountMeta = const VerificationMeta(
    'maxDiscount',
  );
  @override
  late final GeneratedColumn<double> maxDiscount = GeneratedColumn<double>(
    'max_discount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appliesToAllOutletsMeta =
      const VerificationMeta('appliesToAllOutlets');
  @override
  late final GeneratedColumn<bool> appliesToAllOutlets = GeneratedColumn<bool>(
    'applies_to_all_outlets',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("applies_to_all_outlets" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    promoType,
    targetType,
    discountValue,
    maxDiscount,
    appliesToAllOutlets,
    status,
    startDate,
    endDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'promos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Promo> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('promo_type')) {
      context.handle(
        _promoTypeMeta,
        promoType.isAcceptableOrUnknown(data['promo_type']!, _promoTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_promoTypeMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('discount_value')) {
      context.handle(
        _discountValueMeta,
        discountValue.isAcceptableOrUnknown(
          data['discount_value']!,
          _discountValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discountValueMeta);
    }
    if (data.containsKey('max_discount')) {
      context.handle(
        _maxDiscountMeta,
        maxDiscount.isAcceptableOrUnknown(
          data['max_discount']!,
          _maxDiscountMeta,
        ),
      );
    }
    if (data.containsKey('applies_to_all_outlets')) {
      context.handle(
        _appliesToAllOutletsMeta,
        appliesToAllOutlets.isAcceptableOrUnknown(
          data['applies_to_all_outlets']!,
          _appliesToAllOutletsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Promo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Promo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      promoType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}promo_type'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      discountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_value'],
      )!,
      maxDiscount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_discount'],
      ),
      appliesToAllOutlets: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}applies_to_all_outlets'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
    );
  }

  @override
  $PromosTable createAlias(String alias) {
    return $PromosTable(attachedDatabase, alias);
  }
}

class Promo extends DataClass implements Insertable<Promo> {
  final String id;
  final String name;
  final String? description;
  final String promoType;
  final String targetType;
  final double discountValue;
  final double? maxDiscount;
  final bool appliesToAllOutlets;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  const Promo({
    required this.id,
    required this.name,
    this.description,
    required this.promoType,
    required this.targetType,
    required this.discountValue,
    this.maxDiscount,
    required this.appliesToAllOutlets,
    required this.status,
    this.startDate,
    this.endDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['promo_type'] = Variable<String>(promoType);
    map['target_type'] = Variable<String>(targetType);
    map['discount_value'] = Variable<double>(discountValue);
    if (!nullToAbsent || maxDiscount != null) {
      map['max_discount'] = Variable<double>(maxDiscount);
    }
    map['applies_to_all_outlets'] = Variable<bool>(appliesToAllOutlets);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    return map;
  }

  PromosCompanion toCompanion(bool nullToAbsent) {
    return PromosCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      promoType: Value(promoType),
      targetType: Value(targetType),
      discountValue: Value(discountValue),
      maxDiscount: maxDiscount == null && nullToAbsent
          ? const Value.absent()
          : Value(maxDiscount),
      appliesToAllOutlets: Value(appliesToAllOutlets),
      status: Value(status),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
    );
  }

  factory Promo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Promo(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      promoType: serializer.fromJson<String>(json['promoType']),
      targetType: serializer.fromJson<String>(json['targetType']),
      discountValue: serializer.fromJson<double>(json['discountValue']),
      maxDiscount: serializer.fromJson<double?>(json['maxDiscount']),
      appliesToAllOutlets: serializer.fromJson<bool>(
        json['appliesToAllOutlets'],
      ),
      status: serializer.fromJson<String>(json['status']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'promoType': serializer.toJson<String>(promoType),
      'targetType': serializer.toJson<String>(targetType),
      'discountValue': serializer.toJson<double>(discountValue),
      'maxDiscount': serializer.toJson<double?>(maxDiscount),
      'appliesToAllOutlets': serializer.toJson<bool>(appliesToAllOutlets),
      'status': serializer.toJson<String>(status),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
    };
  }

  Promo copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? promoType,
    String? targetType,
    double? discountValue,
    Value<double?> maxDiscount = const Value.absent(),
    bool? appliesToAllOutlets,
    String? status,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
  }) => Promo(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    promoType: promoType ?? this.promoType,
    targetType: targetType ?? this.targetType,
    discountValue: discountValue ?? this.discountValue,
    maxDiscount: maxDiscount.present ? maxDiscount.value : this.maxDiscount,
    appliesToAllOutlets: appliesToAllOutlets ?? this.appliesToAllOutlets,
    status: status ?? this.status,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
  );
  Promo copyWithCompanion(PromosCompanion data) {
    return Promo(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      promoType: data.promoType.present ? data.promoType.value : this.promoType,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
      maxDiscount: data.maxDiscount.present
          ? data.maxDiscount.value
          : this.maxDiscount,
      appliesToAllOutlets: data.appliesToAllOutlets.present
          ? data.appliesToAllOutlets.value
          : this.appliesToAllOutlets,
      status: data.status.present ? data.status.value : this.status,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Promo(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('promoType: $promoType, ')
          ..write('targetType: $targetType, ')
          ..write('discountValue: $discountValue, ')
          ..write('maxDiscount: $maxDiscount, ')
          ..write('appliesToAllOutlets: $appliesToAllOutlets, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    promoType,
    targetType,
    discountValue,
    maxDiscount,
    appliesToAllOutlets,
    status,
    startDate,
    endDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Promo &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.promoType == this.promoType &&
          other.targetType == this.targetType &&
          other.discountValue == this.discountValue &&
          other.maxDiscount == this.maxDiscount &&
          other.appliesToAllOutlets == this.appliesToAllOutlets &&
          other.status == this.status &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class PromosCompanion extends UpdateCompanion<Promo> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> promoType;
  final Value<String> targetType;
  final Value<double> discountValue;
  final Value<double?> maxDiscount;
  final Value<bool> appliesToAllOutlets;
  final Value<String> status;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<int> rowid;
  const PromosCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.promoType = const Value.absent(),
    this.targetType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.maxDiscount = const Value.absent(),
    this.appliesToAllOutlets = const Value.absent(),
    this.status = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromosCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String promoType,
    required String targetType,
    required double discountValue,
    this.maxDiscount = const Value.absent(),
    this.appliesToAllOutlets = const Value.absent(),
    this.status = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       promoType = Value(promoType),
       targetType = Value(targetType),
       discountValue = Value(discountValue);
  static Insertable<Promo> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? promoType,
    Expression<String>? targetType,
    Expression<double>? discountValue,
    Expression<double>? maxDiscount,
    Expression<bool>? appliesToAllOutlets,
    Expression<String>? status,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (promoType != null) 'promo_type': promoType,
      if (targetType != null) 'target_type': targetType,
      if (discountValue != null) 'discount_value': discountValue,
      if (maxDiscount != null) 'max_discount': maxDiscount,
      if (appliesToAllOutlets != null)
        'applies_to_all_outlets': appliesToAllOutlets,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromosCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? promoType,
    Value<String>? targetType,
    Value<double>? discountValue,
    Value<double?>? maxDiscount,
    Value<bool>? appliesToAllOutlets,
    Value<String>? status,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<int>? rowid,
  }) {
    return PromosCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      promoType: promoType ?? this.promoType,
      targetType: targetType ?? this.targetType,
      discountValue: discountValue ?? this.discountValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      appliesToAllOutlets: appliesToAllOutlets ?? this.appliesToAllOutlets,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (promoType.present) {
      map['promo_type'] = Variable<String>(promoType.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<double>(discountValue.value);
    }
    if (maxDiscount.present) {
      map['max_discount'] = Variable<double>(maxDiscount.value);
    }
    if (appliesToAllOutlets.present) {
      map['applies_to_all_outlets'] = Variable<bool>(appliesToAllOutlets.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromosCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('promoType: $promoType, ')
          ..write('targetType: $targetType, ')
          ..write('discountValue: $discountValue, ')
          ..write('maxDiscount: $maxDiscount, ')
          ..write('appliesToAllOutlets: $appliesToAllOutlets, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionPromosTable extends TransactionPromos
    with TableInfo<$TransactionPromosTable, TransactionPromo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionPromosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _promoIdMeta = const VerificationMeta(
    'promoId',
  );
  @override
  late final GeneratedColumn<String> promoId = GeneratedColumn<String>(
    'promo_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES promos (id)',
    ),
  );
  static const VerificationMeta _promoNameMeta = const VerificationMeta(
    'promoName',
  );
  @override
  late final GeneratedColumn<String> promoName = GeneratedColumn<String>(
    'promo_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promoCodeMeta = const VerificationMeta(
    'promoCode',
  );
  @override
  late final GeneratedColumn<String> promoCode = GeneratedColumn<String>(
    'promo_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<String> discountType = GeneratedColumn<String>(
    'discount_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountValueMeta = const VerificationMeta(
    'discountValue',
  );
  @override
  late final GeneratedColumn<double> discountValue = GeneratedColumn<double>(
    'discount_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
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
    transactionId,
    promoId,
    promoName,
    promoCode,
    discountType,
    discountValue,
    discountAmount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_promos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionPromo> instance, {
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
    if (data.containsKey('promo_id')) {
      context.handle(
        _promoIdMeta,
        promoId.isAcceptableOrUnknown(data['promo_id']!, _promoIdMeta),
      );
    }
    if (data.containsKey('promo_name')) {
      context.handle(
        _promoNameMeta,
        promoName.isAcceptableOrUnknown(data['promo_name']!, _promoNameMeta),
      );
    } else if (isInserting) {
      context.missing(_promoNameMeta);
    }
    if (data.containsKey('promo_code')) {
      context.handle(
        _promoCodeMeta,
        promoCode.isAcceptableOrUnknown(data['promo_code']!, _promoCodeMeta),
      );
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discountTypeMeta);
    }
    if (data.containsKey('discount_value')) {
      context.handle(
        _discountValueMeta,
        discountValue.isAcceptableOrUnknown(
          data['discount_value']!,
          _discountValueMeta,
        ),
      );
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
  TransactionPromo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionPromo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      promoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}promo_id'],
      ),
      promoName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}promo_name'],
      )!,
      promoCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}promo_code'],
      ),
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_type'],
      )!,
      discountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_value'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionPromosTable createAlias(String alias) {
    return $TransactionPromosTable(attachedDatabase, alias);
  }
}

class TransactionPromo extends DataClass
    implements Insertable<TransactionPromo> {
  final String id;
  final String transactionId;
  final String? promoId;
  final String promoName;
  final String? promoCode;
  final String discountType;
  final double discountValue;
  final double discountAmount;
  final DateTime createdAt;
  const TransactionPromo({
    required this.id,
    required this.transactionId,
    this.promoId,
    required this.promoName,
    this.promoCode,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    if (!nullToAbsent || promoId != null) {
      map['promo_id'] = Variable<String>(promoId);
    }
    map['promo_name'] = Variable<String>(promoName);
    if (!nullToAbsent || promoCode != null) {
      map['promo_code'] = Variable<String>(promoCode);
    }
    map['discount_type'] = Variable<String>(discountType);
    map['discount_value'] = Variable<double>(discountValue);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionPromosCompanion toCompanion(bool nullToAbsent) {
    return TransactionPromosCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      promoId: promoId == null && nullToAbsent
          ? const Value.absent()
          : Value(promoId),
      promoName: Value(promoName),
      promoCode: promoCode == null && nullToAbsent
          ? const Value.absent()
          : Value(promoCode),
      discountType: Value(discountType),
      discountValue: Value(discountValue),
      discountAmount: Value(discountAmount),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionPromo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionPromo(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      promoId: serializer.fromJson<String?>(json['promoId']),
      promoName: serializer.fromJson<String>(json['promoName']),
      promoCode: serializer.fromJson<String?>(json['promoCode']),
      discountType: serializer.fromJson<String>(json['discountType']),
      discountValue: serializer.fromJson<double>(json['discountValue']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'promoId': serializer.toJson<String?>(promoId),
      'promoName': serializer.toJson<String>(promoName),
      'promoCode': serializer.toJson<String?>(promoCode),
      'discountType': serializer.toJson<String>(discountType),
      'discountValue': serializer.toJson<double>(discountValue),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionPromo copyWith({
    String? id,
    String? transactionId,
    Value<String?> promoId = const Value.absent(),
    String? promoName,
    Value<String?> promoCode = const Value.absent(),
    String? discountType,
    double? discountValue,
    double? discountAmount,
    DateTime? createdAt,
  }) => TransactionPromo(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    promoId: promoId.present ? promoId.value : this.promoId,
    promoName: promoName ?? this.promoName,
    promoCode: promoCode.present ? promoCode.value : this.promoCode,
    discountType: discountType ?? this.discountType,
    discountValue: discountValue ?? this.discountValue,
    discountAmount: discountAmount ?? this.discountAmount,
    createdAt: createdAt ?? this.createdAt,
  );
  TransactionPromo copyWithCompanion(TransactionPromosCompanion data) {
    return TransactionPromo(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      promoId: data.promoId.present ? data.promoId.value : this.promoId,
      promoName: data.promoName.present ? data.promoName.value : this.promoName,
      promoCode: data.promoCode.present ? data.promoCode.value : this.promoCode,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionPromo(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('promoId: $promoId, ')
          ..write('promoName: $promoName, ')
          ..write('promoCode: $promoCode, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    promoId,
    promoName,
    promoCode,
    discountType,
    discountValue,
    discountAmount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionPromo &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.promoId == this.promoId &&
          other.promoName == this.promoName &&
          other.promoCode == this.promoCode &&
          other.discountType == this.discountType &&
          other.discountValue == this.discountValue &&
          other.discountAmount == this.discountAmount &&
          other.createdAt == this.createdAt);
}

class TransactionPromosCompanion extends UpdateCompanion<TransactionPromo> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String?> promoId;
  final Value<String> promoName;
  final Value<String?> promoCode;
  final Value<String> discountType;
  final Value<double> discountValue;
  final Value<double> discountAmount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransactionPromosCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.promoId = const Value.absent(),
    this.promoName = const Value.absent(),
    this.promoCode = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionPromosCompanion.insert({
    required String id,
    required String transactionId,
    this.promoId = const Value.absent(),
    required String promoName,
    this.promoCode = const Value.absent(),
    required String discountType,
    this.discountValue = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       promoName = Value(promoName),
       discountType = Value(discountType);
  static Insertable<TransactionPromo> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? promoId,
    Expression<String>? promoName,
    Expression<String>? promoCode,
    Expression<String>? discountType,
    Expression<double>? discountValue,
    Expression<double>? discountAmount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (promoId != null) 'promo_id': promoId,
      if (promoName != null) 'promo_name': promoName,
      if (promoCode != null) 'promo_code': promoCode,
      if (discountType != null) 'discount_type': discountType,
      if (discountValue != null) 'discount_value': discountValue,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionPromosCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String?>? promoId,
    Value<String>? promoName,
    Value<String?>? promoCode,
    Value<String>? discountType,
    Value<double>? discountValue,
    Value<double>? discountAmount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TransactionPromosCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      promoId: promoId ?? this.promoId,
      promoName: promoName ?? this.promoName,
      promoCode: promoCode ?? this.promoCode,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      discountAmount: discountAmount ?? this.discountAmount,
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
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (promoId.present) {
      map['promo_id'] = Variable<String>(promoId.value);
    }
    if (promoName.present) {
      map['promo_name'] = Variable<String>(promoName.value);
    }
    if (promoCode.present) {
      map['promo_code'] = Variable<String>(promoCode.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<String>(discountType.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<double>(discountValue.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
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
    return (StringBuffer('TransactionPromosCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('promoId: $promoId, ')
          ..write('promoName: $promoName, ')
          ..write('promoCode: $promoCode, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('createdAt: $createdAt, ')
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

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, email, code];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
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
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? code;
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.code,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      code: serializer.fromJson<String?>(json['code']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'code': serializer.toJson<String?>(code),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> code = const Value.absent(),
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    code: code.present ? code.value : this.code,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      code: data.code.present ? data.code.value : this.code,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, email, code);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.code == this.code);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> code;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.code = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.code = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? code,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (code != null) 'code': code,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? code,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      code: code ?? this.code,
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
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('code: $code, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductCategoriesTable productCategories =
      $ProductCategoriesTable(this);
  late final $VariantGroupsTable variantGroups = $VariantGroupsTable(this);
  late final $VariantGroupOptionsTable variantGroupOptions =
      $VariantGroupOptionsTable(this);
  late final $InventoriesTable inventories = $InventoriesTable(this);
  late final $InventoryItemVariantGroupOptionsTable
  inventoryItemVariantGroupOptions = $InventoryItemVariantGroupOptionsTable(
    this,
  );
  late final $ModifierGroupsTable modifierGroups = $ModifierGroupsTable(this);
  late final $ProductModifierGroupsTable productModifierGroups =
      $ProductModifierGroupsTable(this);
  late final $ModifierOptionsTable modifierOptions = $ModifierOptionsTable(
    this,
  );
  late final $ProductPricesTable productPrices = $ProductPricesTable(this);
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
  late final $PromosTable promos = $PromosTable(this);
  late final $TransactionPromosTable transactionPromos =
      $TransactionPromosTable(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    products,
    productCategories,
    variantGroups,
    variantGroupOptions,
    inventories,
    inventoryItemVariantGroupOptions,
    modifierGroups,
    productModifierGroups,
    modifierOptions,
    productPrices,
    paymentMethods,
    outletSettings,
    shifts,
    shiftCashLogs,
    transactions,
    transactionItems,
    transactionItemModifiers,
    transactionPayments,
    promos,
    transactionPromos,
    employees,
    customers,
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

  static MultiTypedResultKey<$VariantGroupsTable, List<VariantGroup>>
  _variantGroupsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.variantGroups,
    aliasName: 'products__id__variant_groups__product_id',
  );

  $$VariantGroupsTableProcessedTableManager get variantGroupsRefs {
    final manager = $$VariantGroupsTableTableManager(
      $_db,
      $_db.variantGroups,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_variantGroupsRefsTable($_db));
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

  static MultiTypedResultKey<
    $ProductModifierGroupsTable,
    List<ProductModifierGroup>
  >
  _productModifierGroupsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productModifierGroups,
        aliasName: 'products__id__product_modifier_groups__product_id',
      );

  $$ProductModifierGroupsTableProcessedTableManager
  get productModifierGroupsRefs {
    final manager = $$ProductModifierGroupsTableTableManager(
      $_db,
      $_db.productModifierGroups,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _productModifierGroupsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProductPricesTable, List<ProductPrice>>
  _productPricesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.productPrices,
    aliasName: 'products__id__product_prices__product_id',
  );

  $$ProductPricesTableProcessedTableManager get productPricesRefs {
    final manager = $$ProductPricesTableTableManager(
      $_db,
      $_db.productPrices,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productPricesRefsTable($_db));
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

  Expression<bool> variantGroupsRefs(
    Expression<bool> Function($$VariantGroupsTableFilterComposer f) f,
  ) {
    final $$VariantGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.variantGroups,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VariantGroupsTableFilterComposer(
            $db: $db,
            $table: $db.variantGroups,
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

  Expression<bool> productModifierGroupsRefs(
    Expression<bool> Function($$ProductModifierGroupsTableFilterComposer f) f,
  ) {
    final $$ProductModifierGroupsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productModifierGroups,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductModifierGroupsTableFilterComposer(
                $db: $db,
                $table: $db.productModifierGroups,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> productPricesRefs(
    Expression<bool> Function($$ProductPricesTableFilterComposer f) f,
  ) {
    final $$ProductPricesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productPrices,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductPricesTableFilterComposer(
            $db: $db,
            $table: $db.productPrices,
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

  Expression<T> variantGroupsRefs<T extends Object>(
    Expression<T> Function($$VariantGroupsTableAnnotationComposer a) f,
  ) {
    final $$VariantGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.variantGroups,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VariantGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.variantGroups,
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

  Expression<T> productModifierGroupsRefs<T extends Object>(
    Expression<T> Function($$ProductModifierGroupsTableAnnotationComposer a) f,
  ) {
    final $$ProductModifierGroupsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productModifierGroups,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductModifierGroupsTableAnnotationComposer(
                $db: $db,
                $table: $db.productModifierGroups,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> productPricesRefs<T extends Object>(
    Expression<T> Function($$ProductPricesTableAnnotationComposer a) f,
  ) {
    final $$ProductPricesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productPrices,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductPricesTableAnnotationComposer(
            $db: $db,
            $table: $db.productPrices,
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
          PrefetchHooks Function({
            bool variantGroupsRefs,
            bool inventoriesRefs,
            bool productModifierGroupsRefs,
            bool productPricesRefs,
          })
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
              ({
                variantGroupsRefs = false,
                inventoriesRefs = false,
                productModifierGroupsRefs = false,
                productPricesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (variantGroupsRefs) db.variantGroups,
                    if (inventoriesRefs) db.inventories,
                    if (productModifierGroupsRefs) db.productModifierGroups,
                    if (productPricesRefs) db.productPrices,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (variantGroupsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          VariantGroup
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._variantGroupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).variantGroupsRefs,
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
                      if (productModifierGroupsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          ProductModifierGroup
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._productModifierGroupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).productModifierGroupsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (productPricesRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          ProductPrice
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._productPricesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).productPricesRefs,
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
      PrefetchHooks Function({
        bool variantGroupsRefs,
        bool inventoriesRefs,
        bool productModifierGroupsRefs,
        bool productPricesRefs,
      })
    >;
typedef $$ProductCategoriesTableCreateCompanionBuilder =
    ProductCategoriesCompanion Function({
      required String id,
      required String name,
      Value<String?> parentId,
      Value<int> rowid,
    });
typedef $$ProductCategoriesTableUpdateCompanionBuilder =
    ProductCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> parentId,
      Value<int> rowid,
    });

class $$ProductCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableFilterComposer({
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

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);
}

class $$ProductCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductCategoriesTable,
          ProductCategory,
          $$ProductCategoriesTableFilterComposer,
          $$ProductCategoriesTableOrderingComposer,
          $$ProductCategoriesTableAnnotationComposer,
          $$ProductCategoriesTableCreateCompanionBuilder,
          $$ProductCategoriesTableUpdateCompanionBuilder,
          (
            ProductCategory,
            BaseReferences<
              _$AppDatabase,
              $ProductCategoriesTable,
              ProductCategory
            >,
          ),
          ProductCategory,
          PrefetchHooks Function()
        > {
  $$ProductCategoriesTableTableManager(
    _$AppDatabase db,
    $ProductCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductCategoriesCompanion(
                id: id,
                name: name,
                parentId: parentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductCategoriesCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductCategoriesTable,
      ProductCategory,
      $$ProductCategoriesTableFilterComposer,
      $$ProductCategoriesTableOrderingComposer,
      $$ProductCategoriesTableAnnotationComposer,
      $$ProductCategoriesTableCreateCompanionBuilder,
      $$ProductCategoriesTableUpdateCompanionBuilder,
      (
        ProductCategory,
        BaseReferences<_$AppDatabase, $ProductCategoriesTable, ProductCategory>,
      ),
      ProductCategory,
      PrefetchHooks Function()
    >;
typedef $$VariantGroupsTableCreateCompanionBuilder =
    VariantGroupsCompanion Function({
      required String id,
      required String productId,
      required String name,
      Value<int> rowid,
    });
typedef $$VariantGroupsTableUpdateCompanionBuilder =
    VariantGroupsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> name,
      Value<int> rowid,
    });

final class $$VariantGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $VariantGroupsTable, VariantGroup> {
  $$VariantGroupsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('variant_groups__product_id__products__id');

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

  static MultiTypedResultKey<
    $VariantGroupOptionsTable,
    List<VariantGroupOption>
  >
  _variantGroupOptionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.variantGroupOptions,
        aliasName:
            'variant_groups__id__variant_group_options__variant_group_id',
      );

  $$VariantGroupOptionsTableProcessedTableManager get variantGroupOptionsRefs {
    final manager = $$VariantGroupOptionsTableTableManager(
      $_db,
      $_db.variantGroupOptions,
    ).filter((f) => f.variantGroupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _variantGroupOptionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VariantGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $VariantGroupsTable> {
  $$VariantGroupsTableFilterComposer({
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

  Expression<bool> variantGroupOptionsRefs(
    Expression<bool> Function($$VariantGroupOptionsTableFilterComposer f) f,
  ) {
    final $$VariantGroupOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.variantGroupOptions,
      getReferencedColumn: (t) => t.variantGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VariantGroupOptionsTableFilterComposer(
            $db: $db,
            $table: $db.variantGroupOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VariantGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $VariantGroupsTable> {
  $$VariantGroupsTableOrderingComposer({
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

class $$VariantGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VariantGroupsTable> {
  $$VariantGroupsTableAnnotationComposer({
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

  Expression<T> variantGroupOptionsRefs<T extends Object>(
    Expression<T> Function($$VariantGroupOptionsTableAnnotationComposer a) f,
  ) {
    final $$VariantGroupOptionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.variantGroupOptions,
          getReferencedColumn: (t) => t.variantGroupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$VariantGroupOptionsTableAnnotationComposer(
                $db: $db,
                $table: $db.variantGroupOptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VariantGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VariantGroupsTable,
          VariantGroup,
          $$VariantGroupsTableFilterComposer,
          $$VariantGroupsTableOrderingComposer,
          $$VariantGroupsTableAnnotationComposer,
          $$VariantGroupsTableCreateCompanionBuilder,
          $$VariantGroupsTableUpdateCompanionBuilder,
          (VariantGroup, $$VariantGroupsTableReferences),
          VariantGroup,
          PrefetchHooks Function({bool productId, bool variantGroupOptionsRefs})
        > {
  $$VariantGroupsTableTableManager(_$AppDatabase db, $VariantGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VariantGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VariantGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VariantGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VariantGroupsCompanion(
                id: id,
                productId: productId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => VariantGroupsCompanion.insert(
                id: id,
                productId: productId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VariantGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({productId = false, variantGroupOptionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (variantGroupOptionsRefs) db.variantGroupOptions,
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
                        if (productId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.productId,
                                    referencedTable:
                                        $$VariantGroupsTableReferences
                                            ._productIdTable(db),
                                    referencedColumn:
                                        $$VariantGroupsTableReferences
                                            ._productIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (variantGroupOptionsRefs)
                        await $_getPrefetchedData<
                          VariantGroup,
                          $VariantGroupsTable,
                          VariantGroupOption
                        >(
                          currentTable: table,
                          referencedTable: $$VariantGroupsTableReferences
                              ._variantGroupOptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VariantGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).variantGroupOptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.variantGroupId == item.id,
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

typedef $$VariantGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VariantGroupsTable,
      VariantGroup,
      $$VariantGroupsTableFilterComposer,
      $$VariantGroupsTableOrderingComposer,
      $$VariantGroupsTableAnnotationComposer,
      $$VariantGroupsTableCreateCompanionBuilder,
      $$VariantGroupsTableUpdateCompanionBuilder,
      (VariantGroup, $$VariantGroupsTableReferences),
      VariantGroup,
      PrefetchHooks Function({bool productId, bool variantGroupOptionsRefs})
    >;
typedef $$VariantGroupOptionsTableCreateCompanionBuilder =
    VariantGroupOptionsCompanion Function({
      required String id,
      required String variantGroupId,
      required String name,
      Value<int> rowid,
    });
typedef $$VariantGroupOptionsTableUpdateCompanionBuilder =
    VariantGroupOptionsCompanion Function({
      Value<String> id,
      Value<String> variantGroupId,
      Value<String> name,
      Value<int> rowid,
    });

final class $$VariantGroupOptionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $VariantGroupOptionsTable,
          VariantGroupOption
        > {
  $$VariantGroupOptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VariantGroupsTable _variantGroupIdTable(_$AppDatabase db) =>
      db.variantGroups.createAlias(
        'variant_group_options__variant_group_id__variant_groups__id',
      );

  $$VariantGroupsTableProcessedTableManager get variantGroupId {
    final $_column = $_itemColumn<String>('variant_group_id')!;

    final manager = $$VariantGroupsTableTableManager(
      $_db,
      $_db.variantGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_variantGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $InventoryItemVariantGroupOptionsTable,
    List<InventoryItemVariantGroupOption>
  >
  _inventoryItemVariantGroupOptionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.inventoryItemVariantGroupOptions,
    aliasName:
        'variant_group_options__id__inventory_item_variant_group_options__variant_group_option_id',
  );

  $$InventoryItemVariantGroupOptionsTableProcessedTableManager
  get inventoryItemVariantGroupOptionsRefs {
    final manager =
        $$InventoryItemVariantGroupOptionsTableTableManager(
          $_db,
          $_db.inventoryItemVariantGroupOptions,
        ).filter(
          (f) =>
              f.variantGroupOptionId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _inventoryItemVariantGroupOptionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VariantGroupOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $VariantGroupOptionsTable> {
  $$VariantGroupOptionsTableFilterComposer({
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

  $$VariantGroupsTableFilterComposer get variantGroupId {
    final $$VariantGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantGroupId,
      referencedTable: $db.variantGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VariantGroupsTableFilterComposer(
            $db: $db,
            $table: $db.variantGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> inventoryItemVariantGroupOptionsRefs(
    Expression<bool> Function(
      $$InventoryItemVariantGroupOptionsTableFilterComposer f,
    )
    f,
  ) {
    final $$InventoryItemVariantGroupOptionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inventoryItemVariantGroupOptions,
          getReferencedColumn: (t) => t.variantGroupOptionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryItemVariantGroupOptionsTableFilterComposer(
                $db: $db,
                $table: $db.inventoryItemVariantGroupOptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VariantGroupOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $VariantGroupOptionsTable> {
  $$VariantGroupOptionsTableOrderingComposer({
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

  $$VariantGroupsTableOrderingComposer get variantGroupId {
    final $$VariantGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantGroupId,
      referencedTable: $db.variantGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VariantGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.variantGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VariantGroupOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VariantGroupOptionsTable> {
  $$VariantGroupOptionsTableAnnotationComposer({
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

  $$VariantGroupsTableAnnotationComposer get variantGroupId {
    final $$VariantGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantGroupId,
      referencedTable: $db.variantGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VariantGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.variantGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> inventoryItemVariantGroupOptionsRefs<T extends Object>(
    Expression<T> Function(
      $$InventoryItemVariantGroupOptionsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$InventoryItemVariantGroupOptionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inventoryItemVariantGroupOptions,
          getReferencedColumn: (t) => t.variantGroupOptionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryItemVariantGroupOptionsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryItemVariantGroupOptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VariantGroupOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VariantGroupOptionsTable,
          VariantGroupOption,
          $$VariantGroupOptionsTableFilterComposer,
          $$VariantGroupOptionsTableOrderingComposer,
          $$VariantGroupOptionsTableAnnotationComposer,
          $$VariantGroupOptionsTableCreateCompanionBuilder,
          $$VariantGroupOptionsTableUpdateCompanionBuilder,
          (VariantGroupOption, $$VariantGroupOptionsTableReferences),
          VariantGroupOption,
          PrefetchHooks Function({
            bool variantGroupId,
            bool inventoryItemVariantGroupOptionsRefs,
          })
        > {
  $$VariantGroupOptionsTableTableManager(
    _$AppDatabase db,
    $VariantGroupOptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VariantGroupOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VariantGroupOptionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VariantGroupOptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> variantGroupId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VariantGroupOptionsCompanion(
                id: id,
                variantGroupId: variantGroupId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String variantGroupId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => VariantGroupOptionsCompanion.insert(
                id: id,
                variantGroupId: variantGroupId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VariantGroupOptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                variantGroupId = false,
                inventoryItemVariantGroupOptionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (inventoryItemVariantGroupOptionsRefs)
                      db.inventoryItemVariantGroupOptions,
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
                        if (variantGroupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.variantGroupId,
                                    referencedTable:
                                        $$VariantGroupOptionsTableReferences
                                            ._variantGroupIdTable(db),
                                    referencedColumn:
                                        $$VariantGroupOptionsTableReferences
                                            ._variantGroupIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (inventoryItemVariantGroupOptionsRefs)
                        await $_getPrefetchedData<
                          VariantGroupOption,
                          $VariantGroupOptionsTable,
                          InventoryItemVariantGroupOption
                        >(
                          currentTable: table,
                          referencedTable: $$VariantGroupOptionsTableReferences
                              ._inventoryItemVariantGroupOptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VariantGroupOptionsTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryItemVariantGroupOptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.variantGroupOptionId == item.id,
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

typedef $$VariantGroupOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VariantGroupOptionsTable,
      VariantGroupOption,
      $$VariantGroupOptionsTableFilterComposer,
      $$VariantGroupOptionsTableOrderingComposer,
      $$VariantGroupOptionsTableAnnotationComposer,
      $$VariantGroupOptionsTableCreateCompanionBuilder,
      $$VariantGroupOptionsTableUpdateCompanionBuilder,
      (VariantGroupOption, $$VariantGroupOptionsTableReferences),
      VariantGroupOption,
      PrefetchHooks Function({
        bool variantGroupId,
        bool inventoryItemVariantGroupOptionsRefs,
      })
    >;
typedef $$InventoriesTableCreateCompanionBuilder =
    InventoriesCompanion Function({
      required String id,
      required String productId,
      required String name,
      Value<String?> sku,
      Value<String?> barcode,
      Value<bool> trackInventory,
      Value<bool> isActive,
      Value<double> stock,
      Value<int> rowid,
    });
typedef $$InventoriesTableUpdateCompanionBuilder =
    InventoriesCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> name,
      Value<String?> sku,
      Value<String?> barcode,
      Value<bool> trackInventory,
      Value<bool> isActive,
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

  static MultiTypedResultKey<
    $InventoryItemVariantGroupOptionsTable,
    List<InventoryItemVariantGroupOption>
  >
  _inventoryItemVariantGroupOptionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.inventoryItemVariantGroupOptions,
    aliasName:
        'inventories__id__inventory_item_variant_group_options__inventory_item_id',
  );

  $$InventoryItemVariantGroupOptionsTableProcessedTableManager
  get inventoryItemVariantGroupOptionsRefs {
    final manager =
        $$InventoryItemVariantGroupOptionsTableTableManager(
          $_db,
          $_db.inventoryItemVariantGroupOptions,
        ).filter(
          (f) => f.inventoryItemId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _inventoryItemVariantGroupOptionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProductPricesTable, List<ProductPrice>>
  _productPricesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.productPrices,
    aliasName: 'inventories__id__product_prices__inventory_item_id',
  );

  $$ProductPricesTableProcessedTableManager get productPricesRefs {
    final manager = $$ProductPricesTableTableManager($_db, $_db.productPrices)
        .filter(
          (f) => f.inventoryItemId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_productPricesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnFilters<bool> get trackInventory => $composableBuilder(
    column: $table.trackInventory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

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

  Expression<bool> inventoryItemVariantGroupOptionsRefs(
    Expression<bool> Function(
      $$InventoryItemVariantGroupOptionsTableFilterComposer f,
    )
    f,
  ) {
    final $$InventoryItemVariantGroupOptionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inventoryItemVariantGroupOptions,
          getReferencedColumn: (t) => t.inventoryItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryItemVariantGroupOptionsTableFilterComposer(
                $db: $db,
                $table: $db.inventoryItemVariantGroupOptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> productPricesRefs(
    Expression<bool> Function($$ProductPricesTableFilterComposer f) f,
  ) {
    final $$ProductPricesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productPrices,
      getReferencedColumn: (t) => t.inventoryItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductPricesTableFilterComposer(
            $db: $db,
            $table: $db.productPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnOrderings<bool> get trackInventory => $composableBuilder(
    column: $table.trackInventory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<bool> get trackInventory => $composableBuilder(
    column: $table.trackInventory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

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

  Expression<T> inventoryItemVariantGroupOptionsRefs<T extends Object>(
    Expression<T> Function(
      $$InventoryItemVariantGroupOptionsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$InventoryItemVariantGroupOptionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inventoryItemVariantGroupOptions,
          getReferencedColumn: (t) => t.inventoryItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryItemVariantGroupOptionsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryItemVariantGroupOptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> productPricesRefs<T extends Object>(
    Expression<T> Function($$ProductPricesTableAnnotationComposer a) f,
  ) {
    final $$ProductPricesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productPrices,
      getReferencedColumn: (t) => t.inventoryItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductPricesTableAnnotationComposer(
            $db: $db,
            $table: $db.productPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
          PrefetchHooks Function({
            bool productId,
            bool inventoryItemVariantGroupOptionsRefs,
            bool productPricesRefs,
          })
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
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<bool> trackInventory = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoriesCompanion(
                id: id,
                productId: productId,
                name: name,
                sku: sku,
                barcode: barcode,
                trackInventory: trackInventory,
                isActive: isActive,
                stock: stock,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String name,
                Value<String?> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<bool> trackInventory = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoriesCompanion.insert(
                id: id,
                productId: productId,
                name: name,
                sku: sku,
                barcode: barcode,
                trackInventory: trackInventory,
                isActive: isActive,
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
          prefetchHooksCallback:
              ({
                productId = false,
                inventoryItemVariantGroupOptionsRefs = false,
                productPricesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (inventoryItemVariantGroupOptionsRefs)
                      db.inventoryItemVariantGroupOptions,
                    if (productPricesRefs) db.productPrices,
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
                        if (productId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.productId,
                                    referencedTable:
                                        $$InventoriesTableReferences
                                            ._productIdTable(db),
                                    referencedColumn:
                                        $$InventoriesTableReferences
                                            ._productIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (inventoryItemVariantGroupOptionsRefs)
                        await $_getPrefetchedData<
                          Inventory,
                          $InventoriesTable,
                          InventoryItemVariantGroupOption
                        >(
                          currentTable: table,
                          referencedTable: $$InventoriesTableReferences
                              ._inventoryItemVariantGroupOptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InventoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryItemVariantGroupOptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.inventoryItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (productPricesRefs)
                        await $_getPrefetchedData<
                          Inventory,
                          $InventoriesTable,
                          ProductPrice
                        >(
                          currentTable: table,
                          referencedTable: $$InventoriesTableReferences
                              ._productPricesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InventoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).productPricesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.inventoryItemId == item.id,
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
      PrefetchHooks Function({
        bool productId,
        bool inventoryItemVariantGroupOptionsRefs,
        bool productPricesRefs,
      })
    >;
typedef $$InventoryItemVariantGroupOptionsTableCreateCompanionBuilder =
    InventoryItemVariantGroupOptionsCompanion Function({
      required String inventoryItemId,
      required String variantGroupOptionId,
      Value<int> rowid,
    });
typedef $$InventoryItemVariantGroupOptionsTableUpdateCompanionBuilder =
    InventoryItemVariantGroupOptionsCompanion Function({
      Value<String> inventoryItemId,
      Value<String> variantGroupOptionId,
      Value<int> rowid,
    });

final class $$InventoryItemVariantGroupOptionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InventoryItemVariantGroupOptionsTable,
          InventoryItemVariantGroupOption
        > {
  $$InventoryItemVariantGroupOptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InventoriesTable _inventoryItemIdTable(
    _$AppDatabase db,
  ) => db.inventories.createAlias(
    'inventory_item_variant_group_options__inventory_item_id__inventories__id',
  );

  $$InventoriesTableProcessedTableManager get inventoryItemId {
    final $_column = $_itemColumn<String>('inventory_item_id')!;

    final manager = $$InventoriesTableTableManager(
      $_db,
      $_db.inventories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inventoryItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VariantGroupOptionsTable _variantGroupOptionIdTable(
    _$AppDatabase db,
  ) => db.variantGroupOptions.createAlias(
    'inventory_item_variant_group_options__variant_group_option_id__variant_group_options__id',
  );

  $$VariantGroupOptionsTableProcessedTableManager get variantGroupOptionId {
    final $_column = $_itemColumn<String>('variant_group_option_id')!;

    final manager = $$VariantGroupOptionsTableTableManager(
      $_db,
      $_db.variantGroupOptions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _variantGroupOptionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InventoryItemVariantGroupOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryItemVariantGroupOptionsTable> {
  $$InventoryItemVariantGroupOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$InventoriesTableFilterComposer get inventoryItemId {
    final $$InventoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryItemId,
      referencedTable: $db.inventories,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$VariantGroupOptionsTableFilterComposer get variantGroupOptionId {
    final $$VariantGroupOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantGroupOptionId,
      referencedTable: $db.variantGroupOptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VariantGroupOptionsTableFilterComposer(
            $db: $db,
            $table: $db.variantGroupOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryItemVariantGroupOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryItemVariantGroupOptionsTable> {
  $$InventoryItemVariantGroupOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$InventoriesTableOrderingComposer get inventoryItemId {
    final $$InventoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryItemId,
      referencedTable: $db.inventories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoriesTableOrderingComposer(
            $db: $db,
            $table: $db.inventories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VariantGroupOptionsTableOrderingComposer get variantGroupOptionId {
    final $$VariantGroupOptionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.variantGroupOptionId,
          referencedTable: $db.variantGroupOptions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$VariantGroupOptionsTableOrderingComposer(
                $db: $db,
                $table: $db.variantGroupOptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$InventoryItemVariantGroupOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryItemVariantGroupOptionsTable> {
  $$InventoryItemVariantGroupOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$InventoriesTableAnnotationComposer get inventoryItemId {
    final $$InventoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryItemId,
      referencedTable: $db.inventories,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$VariantGroupOptionsTableAnnotationComposer get variantGroupOptionId {
    final $$VariantGroupOptionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.variantGroupOptionId,
          referencedTable: $db.variantGroupOptions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$VariantGroupOptionsTableAnnotationComposer(
                $db: $db,
                $table: $db.variantGroupOptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$InventoryItemVariantGroupOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryItemVariantGroupOptionsTable,
          InventoryItemVariantGroupOption,
          $$InventoryItemVariantGroupOptionsTableFilterComposer,
          $$InventoryItemVariantGroupOptionsTableOrderingComposer,
          $$InventoryItemVariantGroupOptionsTableAnnotationComposer,
          $$InventoryItemVariantGroupOptionsTableCreateCompanionBuilder,
          $$InventoryItemVariantGroupOptionsTableUpdateCompanionBuilder,
          (
            InventoryItemVariantGroupOption,
            $$InventoryItemVariantGroupOptionsTableReferences,
          ),
          InventoryItemVariantGroupOption,
          PrefetchHooks Function({
            bool inventoryItemId,
            bool variantGroupOptionId,
          })
        > {
  $$InventoryItemVariantGroupOptionsTableTableManager(
    _$AppDatabase db,
    $InventoryItemVariantGroupOptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryItemVariantGroupOptionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InventoryItemVariantGroupOptionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InventoryItemVariantGroupOptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> inventoryItemId = const Value.absent(),
                Value<String> variantGroupOptionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryItemVariantGroupOptionsCompanion(
                inventoryItemId: inventoryItemId,
                variantGroupOptionId: variantGroupOptionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String inventoryItemId,
                required String variantGroupOptionId,
                Value<int> rowid = const Value.absent(),
              }) => InventoryItemVariantGroupOptionsCompanion.insert(
                inventoryItemId: inventoryItemId,
                variantGroupOptionId: variantGroupOptionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InventoryItemVariantGroupOptionsTableReferences(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({inventoryItemId = false, variantGroupOptionId = false}) {
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
                    if (inventoryItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.inventoryItemId,
                                referencedTable:
                                    $$InventoryItemVariantGroupOptionsTableReferences
                                        ._inventoryItemIdTable(db),
                                referencedColumn:
                                    $$InventoryItemVariantGroupOptionsTableReferences
                                        ._inventoryItemIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (variantGroupOptionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.variantGroupOptionId,
                                referencedTable:
                                    $$InventoryItemVariantGroupOptionsTableReferences
                                        ._variantGroupOptionIdTable(db),
                                referencedColumn:
                                    $$InventoryItemVariantGroupOptionsTableReferences
                                        ._variantGroupOptionIdTable(db)
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

typedef $$InventoryItemVariantGroupOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryItemVariantGroupOptionsTable,
      InventoryItemVariantGroupOption,
      $$InventoryItemVariantGroupOptionsTableFilterComposer,
      $$InventoryItemVariantGroupOptionsTableOrderingComposer,
      $$InventoryItemVariantGroupOptionsTableAnnotationComposer,
      $$InventoryItemVariantGroupOptionsTableCreateCompanionBuilder,
      $$InventoryItemVariantGroupOptionsTableUpdateCompanionBuilder,
      (
        InventoryItemVariantGroupOption,
        $$InventoryItemVariantGroupOptionsTableReferences,
      ),
      InventoryItemVariantGroupOption,
      PrefetchHooks Function({bool inventoryItemId, bool variantGroupOptionId})
    >;
typedef $$ModifierGroupsTableCreateCompanionBuilder =
    ModifierGroupsCompanion Function({
      required String id,
      required String name,
      Value<String?> type,
      Value<int> minSelected,
      Value<int> maxSelected,
      Value<int> rowid,
    });
typedef $$ModifierGroupsTableUpdateCompanionBuilder =
    ModifierGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> type,
      Value<int> minSelected,
      Value<int> maxSelected,
      Value<int> rowid,
    });

final class $$ModifierGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $ModifierGroupsTable, ModifierGroup> {
  $$ModifierGroupsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ProductModifierGroupsTable,
    List<ProductModifierGroup>
  >
  _productModifierGroupsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productModifierGroups,
        aliasName:
            'modifier_groups__id__product_modifier_groups__modifier_group_id',
      );

  $$ProductModifierGroupsTableProcessedTableManager
  get productModifierGroupsRefs {
    final manager =
        $$ProductModifierGroupsTableTableManager(
          $_db,
          $_db.productModifierGroups,
        ).filter(
          (f) => f.modifierGroupId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _productModifierGroupsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ModifierOptionsTable, List<ModifierOption>>
  _modifierOptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.modifierOptions,
    aliasName: 'modifier_groups__id__modifier_options__modifier_group_id',
  );

  $$ModifierOptionsTableProcessedTableManager get modifierOptionsRefs {
    final manager =
        $$ModifierOptionsTableTableManager($_db, $_db.modifierOptions).filter(
          (f) => f.modifierGroupId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _modifierOptionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ModifierGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $ModifierGroupsTable> {
  $$ModifierGroupsTableFilterComposer({
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

  ColumnFilters<int> get minSelected => $composableBuilder(
    column: $table.minSelected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxSelected => $composableBuilder(
    column: $table.maxSelected,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productModifierGroupsRefs(
    Expression<bool> Function($$ProductModifierGroupsTableFilterComposer f) f,
  ) {
    final $$ProductModifierGroupsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productModifierGroups,
          getReferencedColumn: (t) => t.modifierGroupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductModifierGroupsTableFilterComposer(
                $db: $db,
                $table: $db.productModifierGroups,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> modifierOptionsRefs(
    Expression<bool> Function($$ModifierOptionsTableFilterComposer f) f,
  ) {
    final $$ModifierOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.modifierOptions,
      getReferencedColumn: (t) => t.modifierGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModifierOptionsTableFilterComposer(
            $db: $db,
            $table: $db.modifierOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ModifierGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $ModifierGroupsTable> {
  $$ModifierGroupsTableOrderingComposer({
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

  ColumnOrderings<int> get minSelected => $composableBuilder(
    column: $table.minSelected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxSelected => $composableBuilder(
    column: $table.maxSelected,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModifierGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModifierGroupsTable> {
  $$ModifierGroupsTableAnnotationComposer({
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

  GeneratedColumn<int> get minSelected => $composableBuilder(
    column: $table.minSelected,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxSelected => $composableBuilder(
    column: $table.maxSelected,
    builder: (column) => column,
  );

  Expression<T> productModifierGroupsRefs<T extends Object>(
    Expression<T> Function($$ProductModifierGroupsTableAnnotationComposer a) f,
  ) {
    final $$ProductModifierGroupsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productModifierGroups,
          getReferencedColumn: (t) => t.modifierGroupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductModifierGroupsTableAnnotationComposer(
                $db: $db,
                $table: $db.productModifierGroups,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> modifierOptionsRefs<T extends Object>(
    Expression<T> Function($$ModifierOptionsTableAnnotationComposer a) f,
  ) {
    final $$ModifierOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.modifierOptions,
      getReferencedColumn: (t) => t.modifierGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModifierOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.modifierOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ModifierGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModifierGroupsTable,
          ModifierGroup,
          $$ModifierGroupsTableFilterComposer,
          $$ModifierGroupsTableOrderingComposer,
          $$ModifierGroupsTableAnnotationComposer,
          $$ModifierGroupsTableCreateCompanionBuilder,
          $$ModifierGroupsTableUpdateCompanionBuilder,
          (ModifierGroup, $$ModifierGroupsTableReferences),
          ModifierGroup,
          PrefetchHooks Function({
            bool productModifierGroupsRefs,
            bool modifierOptionsRefs,
          })
        > {
  $$ModifierGroupsTableTableManager(
    _$AppDatabase db,
    $ModifierGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModifierGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModifierGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModifierGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<int> minSelected = const Value.absent(),
                Value<int> maxSelected = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModifierGroupsCompanion(
                id: id,
                name: name,
                type: type,
                minSelected: minSelected,
                maxSelected: maxSelected,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> type = const Value.absent(),
                Value<int> minSelected = const Value.absent(),
                Value<int> maxSelected = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModifierGroupsCompanion.insert(
                id: id,
                name: name,
                type: type,
                minSelected: minSelected,
                maxSelected: maxSelected,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ModifierGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                productModifierGroupsRefs = false,
                modifierOptionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (productModifierGroupsRefs) db.productModifierGroups,
                    if (modifierOptionsRefs) db.modifierOptions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (productModifierGroupsRefs)
                        await $_getPrefetchedData<
                          ModifierGroup,
                          $ModifierGroupsTable,
                          ProductModifierGroup
                        >(
                          currentTable: table,
                          referencedTable: $$ModifierGroupsTableReferences
                              ._productModifierGroupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ModifierGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).productModifierGroupsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.modifierGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (modifierOptionsRefs)
                        await $_getPrefetchedData<
                          ModifierGroup,
                          $ModifierGroupsTable,
                          ModifierOption
                        >(
                          currentTable: table,
                          referencedTable: $$ModifierGroupsTableReferences
                              ._modifierOptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ModifierGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).modifierOptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.modifierGroupId == item.id,
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

typedef $$ModifierGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModifierGroupsTable,
      ModifierGroup,
      $$ModifierGroupsTableFilterComposer,
      $$ModifierGroupsTableOrderingComposer,
      $$ModifierGroupsTableAnnotationComposer,
      $$ModifierGroupsTableCreateCompanionBuilder,
      $$ModifierGroupsTableUpdateCompanionBuilder,
      (ModifierGroup, $$ModifierGroupsTableReferences),
      ModifierGroup,
      PrefetchHooks Function({
        bool productModifierGroupsRefs,
        bool modifierOptionsRefs,
      })
    >;
typedef $$ProductModifierGroupsTableCreateCompanionBuilder =
    ProductModifierGroupsCompanion Function({
      required String productId,
      required String modifierGroupId,
      Value<int> rowid,
    });
typedef $$ProductModifierGroupsTableUpdateCompanionBuilder =
    ProductModifierGroupsCompanion Function({
      Value<String> productId,
      Value<String> modifierGroupId,
      Value<int> rowid,
    });

final class $$ProductModifierGroupsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProductModifierGroupsTable,
          ProductModifierGroup
        > {
  $$ProductModifierGroupsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) => db.products
      .createAlias('product_modifier_groups__product_id__products__id');

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

  static $ModifierGroupsTable _modifierGroupIdTable(_$AppDatabase db) =>
      db.modifierGroups.createAlias(
        'product_modifier_groups__modifier_group_id__modifier_groups__id',
      );

  $$ModifierGroupsTableProcessedTableManager get modifierGroupId {
    final $_column = $_itemColumn<String>('modifier_group_id')!;

    final manager = $$ModifierGroupsTableTableManager(
      $_db,
      $_db.modifierGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modifierGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductModifierGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductModifierGroupsTable> {
  $$ProductModifierGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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

  $$ModifierGroupsTableFilterComposer get modifierGroupId {
    final $$ModifierGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modifierGroupId,
      referencedTable: $db.modifierGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModifierGroupsTableFilterComposer(
            $db: $db,
            $table: $db.modifierGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductModifierGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductModifierGroupsTable> {
  $$ProductModifierGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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

  $$ModifierGroupsTableOrderingComposer get modifierGroupId {
    final $$ModifierGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modifierGroupId,
      referencedTable: $db.modifierGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModifierGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.modifierGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductModifierGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductModifierGroupsTable> {
  $$ProductModifierGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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

  $$ModifierGroupsTableAnnotationComposer get modifierGroupId {
    final $$ModifierGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modifierGroupId,
      referencedTable: $db.modifierGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModifierGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.modifierGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductModifierGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductModifierGroupsTable,
          ProductModifierGroup,
          $$ProductModifierGroupsTableFilterComposer,
          $$ProductModifierGroupsTableOrderingComposer,
          $$ProductModifierGroupsTableAnnotationComposer,
          $$ProductModifierGroupsTableCreateCompanionBuilder,
          $$ProductModifierGroupsTableUpdateCompanionBuilder,
          (ProductModifierGroup, $$ProductModifierGroupsTableReferences),
          ProductModifierGroup,
          PrefetchHooks Function({bool productId, bool modifierGroupId})
        > {
  $$ProductModifierGroupsTableTableManager(
    _$AppDatabase db,
    $ProductModifierGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductModifierGroupsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProductModifierGroupsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProductModifierGroupsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> productId = const Value.absent(),
                Value<String> modifierGroupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductModifierGroupsCompanion(
                productId: productId,
                modifierGroupId: modifierGroupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productId,
                required String modifierGroupId,
                Value<int> rowid = const Value.absent(),
              }) => ProductModifierGroupsCompanion.insert(
                productId: productId,
                modifierGroupId: modifierGroupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductModifierGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({productId = false, modifierGroupId = false}) {
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
                                    referencedTable:
                                        $$ProductModifierGroupsTableReferences
                                            ._productIdTable(db),
                                    referencedColumn:
                                        $$ProductModifierGroupsTableReferences
                                            ._productIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (modifierGroupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.modifierGroupId,
                                    referencedTable:
                                        $$ProductModifierGroupsTableReferences
                                            ._modifierGroupIdTable(db),
                                    referencedColumn:
                                        $$ProductModifierGroupsTableReferences
                                            ._modifierGroupIdTable(db)
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

typedef $$ProductModifierGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductModifierGroupsTable,
      ProductModifierGroup,
      $$ProductModifierGroupsTableFilterComposer,
      $$ProductModifierGroupsTableOrderingComposer,
      $$ProductModifierGroupsTableAnnotationComposer,
      $$ProductModifierGroupsTableCreateCompanionBuilder,
      $$ProductModifierGroupsTableUpdateCompanionBuilder,
      (ProductModifierGroup, $$ProductModifierGroupsTableReferences),
      ProductModifierGroup,
      PrefetchHooks Function({bool productId, bool modifierGroupId})
    >;
typedef $$ModifierOptionsTableCreateCompanionBuilder =
    ModifierOptionsCompanion Function({
      required String id,
      required String modifierGroupId,
      required String name,
      Value<double> price,
      Value<int> rowid,
    });
typedef $$ModifierOptionsTableUpdateCompanionBuilder =
    ModifierOptionsCompanion Function({
      Value<String> id,
      Value<String> modifierGroupId,
      Value<String> name,
      Value<double> price,
      Value<int> rowid,
    });

final class $$ModifierOptionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ModifierOptionsTable, ModifierOption> {
  $$ModifierOptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ModifierGroupsTable _modifierGroupIdTable(_$AppDatabase db) => db
      .modifierGroups
      .createAlias('modifier_options__modifier_group_id__modifier_groups__id');

  $$ModifierGroupsTableProcessedTableManager get modifierGroupId {
    final $_column = $_itemColumn<String>('modifier_group_id')!;

    final manager = $$ModifierGroupsTableTableManager(
      $_db,
      $_db.modifierGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modifierGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ModifierOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $ModifierOptionsTable> {
  $$ModifierOptionsTableFilterComposer({
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

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  $$ModifierGroupsTableFilterComposer get modifierGroupId {
    final $$ModifierGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modifierGroupId,
      referencedTable: $db.modifierGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModifierGroupsTableFilterComposer(
            $db: $db,
            $table: $db.modifierGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ModifierOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ModifierOptionsTable> {
  $$ModifierOptionsTableOrderingComposer({
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

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  $$ModifierGroupsTableOrderingComposer get modifierGroupId {
    final $$ModifierGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modifierGroupId,
      referencedTable: $db.modifierGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModifierGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.modifierGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ModifierOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModifierOptionsTable> {
  $$ModifierOptionsTableAnnotationComposer({
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

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  $$ModifierGroupsTableAnnotationComposer get modifierGroupId {
    final $$ModifierGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modifierGroupId,
      referencedTable: $db.modifierGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModifierGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.modifierGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ModifierOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModifierOptionsTable,
          ModifierOption,
          $$ModifierOptionsTableFilterComposer,
          $$ModifierOptionsTableOrderingComposer,
          $$ModifierOptionsTableAnnotationComposer,
          $$ModifierOptionsTableCreateCompanionBuilder,
          $$ModifierOptionsTableUpdateCompanionBuilder,
          (ModifierOption, $$ModifierOptionsTableReferences),
          ModifierOption,
          PrefetchHooks Function({bool modifierGroupId})
        > {
  $$ModifierOptionsTableTableManager(
    _$AppDatabase db,
    $ModifierOptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModifierOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModifierOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModifierOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> modifierGroupId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModifierOptionsCompanion(
                id: id,
                modifierGroupId: modifierGroupId,
                name: name,
                price: price,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String modifierGroupId,
                required String name,
                Value<double> price = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModifierOptionsCompanion.insert(
                id: id,
                modifierGroupId: modifierGroupId,
                name: name,
                price: price,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ModifierOptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({modifierGroupId = false}) {
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
                    if (modifierGroupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.modifierGroupId,
                                referencedTable:
                                    $$ModifierOptionsTableReferences
                                        ._modifierGroupIdTable(db),
                                referencedColumn:
                                    $$ModifierOptionsTableReferences
                                        ._modifierGroupIdTable(db)
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

typedef $$ModifierOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModifierOptionsTable,
      ModifierOption,
      $$ModifierOptionsTableFilterComposer,
      $$ModifierOptionsTableOrderingComposer,
      $$ModifierOptionsTableAnnotationComposer,
      $$ModifierOptionsTableCreateCompanionBuilder,
      $$ModifierOptionsTableUpdateCompanionBuilder,
      (ModifierOption, $$ModifierOptionsTableReferences),
      ModifierOption,
      PrefetchHooks Function({bool modifierGroupId})
    >;
typedef $$ProductPricesTableCreateCompanionBuilder =
    ProductPricesCompanion Function({
      required String id,
      required String productId,
      Value<String?> inventoryItemId,
      Value<double> amount,
      Value<int> rowid,
    });
typedef $$ProductPricesTableUpdateCompanionBuilder =
    ProductPricesCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String?> inventoryItemId,
      Value<double> amount,
      Value<int> rowid,
    });

final class $$ProductPricesTableReferences
    extends BaseReferences<_$AppDatabase, $ProductPricesTable, ProductPrice> {
  $$ProductPricesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('product_prices__product_id__products__id');

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

  static $InventoriesTable _inventoryItemIdTable(_$AppDatabase db) => db
      .inventories
      .createAlias('product_prices__inventory_item_id__inventories__id');

  $$InventoriesTableProcessedTableManager? get inventoryItemId {
    final $_column = $_itemColumn<String>('inventory_item_id');
    if ($_column == null) return null;
    final manager = $$InventoriesTableTableManager(
      $_db,
      $_db.inventories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inventoryItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductPricesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductPricesTable> {
  $$ProductPricesTableFilterComposer({
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

  $$InventoriesTableFilterComposer get inventoryItemId {
    final $$InventoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryItemId,
      referencedTable: $db.inventories,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$ProductPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductPricesTable> {
  $$ProductPricesTableOrderingComposer({
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

  $$InventoriesTableOrderingComposer get inventoryItemId {
    final $$InventoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryItemId,
      referencedTable: $db.inventories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoriesTableOrderingComposer(
            $db: $db,
            $table: $db.inventories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductPricesTable> {
  $$ProductPricesTableAnnotationComposer({
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

  $$InventoriesTableAnnotationComposer get inventoryItemId {
    final $$InventoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryItemId,
      referencedTable: $db.inventories,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$ProductPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductPricesTable,
          ProductPrice,
          $$ProductPricesTableFilterComposer,
          $$ProductPricesTableOrderingComposer,
          $$ProductPricesTableAnnotationComposer,
          $$ProductPricesTableCreateCompanionBuilder,
          $$ProductPricesTableUpdateCompanionBuilder,
          (ProductPrice, $$ProductPricesTableReferences),
          ProductPrice,
          PrefetchHooks Function({bool productId, bool inventoryItemId})
        > {
  $$ProductPricesTableTableManager(_$AppDatabase db, $ProductPricesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String?> inventoryItemId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductPricesCompanion(
                id: id,
                productId: productId,
                inventoryItemId: inventoryItemId,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                Value<String?> inventoryItemId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductPricesCompanion.insert(
                id: id,
                productId: productId,
                inventoryItemId: inventoryItemId,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductPricesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({productId = false, inventoryItemId = false}) {
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
                                    referencedTable:
                                        $$ProductPricesTableReferences
                                            ._productIdTable(db),
                                    referencedColumn:
                                        $$ProductPricesTableReferences
                                            ._productIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (inventoryItemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.inventoryItemId,
                                    referencedTable:
                                        $$ProductPricesTableReferences
                                            ._inventoryItemIdTable(db),
                                    referencedColumn:
                                        $$ProductPricesTableReferences
                                            ._inventoryItemIdTable(db)
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

typedef $$ProductPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductPricesTable,
      ProductPrice,
      $$ProductPricesTableFilterComposer,
      $$ProductPricesTableOrderingComposer,
      $$ProductPricesTableAnnotationComposer,
      $$ProductPricesTableCreateCompanionBuilder,
      $$ProductPricesTableUpdateCompanionBuilder,
      (ProductPrice, $$ProductPricesTableReferences),
      ProductPrice,
      PrefetchHooks Function({bool productId, bool inventoryItemId})
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
      Value<String> channel,
      required String transactionNumber,
      required double subtotal,
      Value<double> discountAmount,
      Value<String?> discountType,
      Value<double?> discountValue,
      Value<String?> promoName,
      Value<double> taxAmount,
      Value<double> serviceChargeAmount,
      Value<double> shippingFee,
      required double total,
      required String paymentStatus,
      required String status,
      Value<String?> notes,
      Value<bool> isOffline,
      Value<String?> offlineId,
      Value<DateTime?> dueDate,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> outletId,
      Value<String?> shiftId,
      Value<String?> customerId,
      Value<String> channel,
      Value<String> transactionNumber,
      Value<double> subtotal,
      Value<double> discountAmount,
      Value<String?> discountType,
      Value<double?> discountValue,
      Value<String?> promoName,
      Value<double> taxAmount,
      Value<double> serviceChargeAmount,
      Value<double> shippingFee,
      Value<double> total,
      Value<String> paymentStatus,
      Value<String> status,
      Value<String?> notes,
      Value<bool> isOffline,
      Value<String?> offlineId,
      Value<DateTime?> dueDate,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
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

  static MultiTypedResultKey<$TransactionPromosTable, List<TransactionPromo>>
  _transactionPromosRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionPromos,
        aliasName: 'transactions__id__transaction_promos__transaction_id',
      );

  $$TransactionPromosTableProcessedTableManager get transactionPromosRefs {
    final manager = $$TransactionPromosTableTableManager(
      $_db,
      $_db.transactionPromos,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionPromosRefsTable($_db),
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

  ColumnFilters<String> get transactionNumber => $composableBuilder(
    column: $table.transactionNumber,
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

  ColumnFilters<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promoName => $composableBuilder(
    column: $table.promoName,
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

  ColumnFilters<double> get shippingFee => $composableBuilder(
    column: $table.shippingFee,
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

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  Expression<bool> transactionPromosRefs(
    Expression<bool> Function($$TransactionPromosTableFilterComposer f) f,
  ) {
    final $$TransactionPromosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionPromos,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionPromosTableFilterComposer(
            $db: $db,
            $table: $db.transactionPromos,
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

  ColumnOrderings<String> get transactionNumber => $composableBuilder(
    column: $table.transactionNumber,
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

  ColumnOrderings<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promoName => $composableBuilder(
    column: $table.promoName,
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

  ColumnOrderings<double> get shippingFee => $composableBuilder(
    column: $table.shippingFee,
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

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  GeneratedColumn<String> get transactionNumber => $composableBuilder(
    column: $table.transactionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get promoName =>
      $composableBuilder(column: $table.promoName, builder: (column) => column);

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get serviceChargeAmount => $composableBuilder(
    column: $table.serviceChargeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get shippingFee => $composableBuilder(
    column: $table.shippingFee,
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

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isOffline =>
      $composableBuilder(column: $table.isOffline, builder: (column) => column);

  GeneratedColumn<String> get offlineId =>
      $composableBuilder(column: $table.offlineId, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

  Expression<T> transactionPromosRefs<T extends Object>(
    Expression<T> Function($$TransactionPromosTableAnnotationComposer a) f,
  ) {
    final $$TransactionPromosTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionPromos,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionPromosTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionPromos,
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
            bool transactionPromosRefs,
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
                Value<String> transactionNumber = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<String?> discountType = const Value.absent(),
                Value<double?> discountValue = const Value.absent(),
                Value<String?> promoName = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> serviceChargeAmount = const Value.absent(),
                Value<double> shippingFee = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isOffline = const Value.absent(),
                Value<String?> offlineId = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                outletId: outletId,
                shiftId: shiftId,
                customerId: customerId,
                channel: channel,
                transactionNumber: transactionNumber,
                subtotal: subtotal,
                discountAmount: discountAmount,
                discountType: discountType,
                discountValue: discountValue,
                promoName: promoName,
                taxAmount: taxAmount,
                serviceChargeAmount: serviceChargeAmount,
                shippingFee: shippingFee,
                total: total,
                paymentStatus: paymentStatus,
                status: status,
                notes: notes,
                isOffline: isOffline,
                offlineId: offlineId,
                dueDate: dueDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String outletId,
                Value<String?> shiftId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> channel = const Value.absent(),
                required String transactionNumber,
                required double subtotal,
                Value<double> discountAmount = const Value.absent(),
                Value<String?> discountType = const Value.absent(),
                Value<double?> discountValue = const Value.absent(),
                Value<String?> promoName = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> serviceChargeAmount = const Value.absent(),
                Value<double> shippingFee = const Value.absent(),
                required double total,
                required String paymentStatus,
                required String status,
                Value<String?> notes = const Value.absent(),
                Value<bool> isOffline = const Value.absent(),
                Value<String?> offlineId = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                outletId: outletId,
                shiftId: shiftId,
                customerId: customerId,
                channel: channel,
                transactionNumber: transactionNumber,
                subtotal: subtotal,
                discountAmount: discountAmount,
                discountType: discountType,
                discountValue: discountValue,
                promoName: promoName,
                taxAmount: taxAmount,
                serviceChargeAmount: serviceChargeAmount,
                shippingFee: shippingFee,
                total: total,
                paymentStatus: paymentStatus,
                status: status,
                notes: notes,
                isOffline: isOffline,
                offlineId: offlineId,
                dueDate: dueDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
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
                transactionPromosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionItemsRefs) db.transactionItems,
                    if (transactionPaymentsRefs) db.transactionPayments,
                    if (transactionPromosRefs) db.transactionPromos,
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
                      if (transactionPromosRefs)
                        await $_getPrefetchedData<
                          Transaction,
                          $TransactionsTable,
                          TransactionPromo
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._transactionPromosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionPromosRefs,
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
        bool transactionPromosRefs,
      })
    >;
typedef $$TransactionItemsTableCreateCompanionBuilder =
    TransactionItemsCompanion Function({
      required String id,
      required String transactionId,
      Value<String?> productId,
      Value<String?> inventoryItemId,
      Value<String?> variantGroupOptionId,
      required String productName,
      required double price,
      required double qty,
      Value<double> discountAmount,
      Value<String?> promoName,
      required double subtotal,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TransactionItemsTableUpdateCompanionBuilder =
    TransactionItemsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String?> productId,
      Value<String?> inventoryItemId,
      Value<String?> variantGroupOptionId,
      Value<String> productName,
      Value<double> price,
      Value<double> qty,
      Value<double> discountAmount,
      Value<String?> promoName,
      Value<double> subtotal,
      Value<String?> notes,
      Value<DateTime> createdAt,
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

  ColumnFilters<String> get inventoryItemId => $composableBuilder(
    column: $table.inventoryItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantGroupOptionId => $composableBuilder(
    column: $table.variantGroupOptionId,
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

  ColumnFilters<String> get promoName => $composableBuilder(
    column: $table.promoName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  ColumnOrderings<String> get inventoryItemId => $composableBuilder(
    column: $table.inventoryItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantGroupOptionId => $composableBuilder(
    column: $table.variantGroupOptionId,
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

  ColumnOrderings<String> get promoName => $composableBuilder(
    column: $table.promoName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  GeneratedColumn<String> get inventoryItemId => $composableBuilder(
    column: $table.inventoryItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variantGroupOptionId => $composableBuilder(
    column: $table.variantGroupOptionId,
    builder: (column) => column,
  );

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

  GeneratedColumn<String> get promoName =>
      $composableBuilder(column: $table.promoName, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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
                Value<String?> productId = const Value.absent(),
                Value<String?> inventoryItemId = const Value.absent(),
                Value<String?> variantGroupOptionId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double> qty = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<String?> promoName = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemsCompanion(
                id: id,
                transactionId: transactionId,
                productId: productId,
                inventoryItemId: inventoryItemId,
                variantGroupOptionId: variantGroupOptionId,
                productName: productName,
                price: price,
                qty: qty,
                discountAmount: discountAmount,
                promoName: promoName,
                subtotal: subtotal,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                Value<String?> productId = const Value.absent(),
                Value<String?> inventoryItemId = const Value.absent(),
                Value<String?> variantGroupOptionId = const Value.absent(),
                required String productName,
                required double price,
                required double qty,
                Value<double> discountAmount = const Value.absent(),
                Value<String?> promoName = const Value.absent(),
                required double subtotal,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemsCompanion.insert(
                id: id,
                transactionId: transactionId,
                productId: productId,
                inventoryItemId: inventoryItemId,
                variantGroupOptionId: variantGroupOptionId,
                productName: productName,
                price: price,
                qty: qty,
                discountAmount: discountAmount,
                promoName: promoName,
                subtotal: subtotal,
                notes: notes,
                createdAt: createdAt,
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
      Value<String?> modifierOptionId,
      required String modifierName,
      Value<double> price,
      Value<double> qty,
      Value<int> rowid,
    });
typedef $$TransactionItemModifiersTableUpdateCompanionBuilder =
    TransactionItemModifiersCompanion Function({
      Value<String> id,
      Value<String> transactionItemId,
      Value<String?> modifierOptionId,
      Value<String> modifierName,
      Value<double> price,
      Value<double> qty,
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

  ColumnFilters<String> get modifierOptionId => $composableBuilder(
    column: $table.modifierOptionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifierName => $composableBuilder(
    column: $table.modifierName,
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

  ColumnOrderings<String> get modifierOptionId => $composableBuilder(
    column: $table.modifierOptionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifierName => $composableBuilder(
    column: $table.modifierName,
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

  GeneratedColumn<String> get modifierOptionId => $composableBuilder(
    column: $table.modifierOptionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modifierName => $composableBuilder(
    column: $table.modifierName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

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
                Value<String?> modifierOptionId = const Value.absent(),
                Value<String> modifierName = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double> qty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemModifiersCompanion(
                id: id,
                transactionItemId: transactionItemId,
                modifierOptionId: modifierOptionId,
                modifierName: modifierName,
                price: price,
                qty: qty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionItemId,
                Value<String?> modifierOptionId = const Value.absent(),
                required String modifierName,
                Value<double> price = const Value.absent(),
                Value<double> qty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemModifiersCompanion.insert(
                id: id,
                transactionItemId: transactionItemId,
                modifierOptionId: modifierOptionId,
                modifierName: modifierName,
                price: price,
                qty: qty,
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
      Value<String?> paymentMethodId,
      required double amount,
      Value<double> changeAmount,
      Value<String?> paymentReference,
      Value<DateTime> paidAt,
      Value<int> rowid,
    });
typedef $$TransactionPaymentsTableUpdateCompanionBuilder =
    TransactionPaymentsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String?> paymentMethodId,
      Value<double> amount,
      Value<double> changeAmount,
      Value<String?> paymentReference,
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

  $$PaymentMethodsTableProcessedTableManager? get paymentMethodId {
    final $_column = $_itemColumn<String>('payment_method_id');
    if ($_column == null) return null;
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

  ColumnFilters<String> get paymentReference => $composableBuilder(
    column: $table.paymentReference,
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

  ColumnOrderings<String> get paymentReference => $composableBuilder(
    column: $table.paymentReference,
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

  GeneratedColumn<String> get paymentReference => $composableBuilder(
    column: $table.paymentReference,
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
                Value<String?> paymentMethodId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> changeAmount = const Value.absent(),
                Value<String?> paymentReference = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionPaymentsCompanion(
                id: id,
                transactionId: transactionId,
                paymentMethodId: paymentMethodId,
                amount: amount,
                changeAmount: changeAmount,
                paymentReference: paymentReference,
                paidAt: paidAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                Value<String?> paymentMethodId = const Value.absent(),
                required double amount,
                Value<double> changeAmount = const Value.absent(),
                Value<String?> paymentReference = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionPaymentsCompanion.insert(
                id: id,
                transactionId: transactionId,
                paymentMethodId: paymentMethodId,
                amount: amount,
                changeAmount: changeAmount,
                paymentReference: paymentReference,
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
typedef $$PromosTableCreateCompanionBuilder =
    PromosCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required String promoType,
      required String targetType,
      required double discountValue,
      Value<double?> maxDiscount,
      Value<bool> appliesToAllOutlets,
      Value<String> status,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<int> rowid,
    });
typedef $$PromosTableUpdateCompanionBuilder =
    PromosCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> promoType,
      Value<String> targetType,
      Value<double> discountValue,
      Value<double?> maxDiscount,
      Value<bool> appliesToAllOutlets,
      Value<String> status,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<int> rowid,
    });

final class $$PromosTableReferences
    extends BaseReferences<_$AppDatabase, $PromosTable, Promo> {
  $$PromosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionPromosTable, List<TransactionPromo>>
  _transactionPromosRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionPromos,
        aliasName: 'promos__id__transaction_promos__promo_id',
      );

  $$TransactionPromosTableProcessedTableManager get transactionPromosRefs {
    final manager = $$TransactionPromosTableTableManager(
      $_db,
      $_db.transactionPromos,
    ).filter((f) => f.promoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionPromosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PromosTableFilterComposer
    extends Composer<_$AppDatabase, $PromosTable> {
  $$PromosTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promoType => $composableBuilder(
    column: $table.promoType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxDiscount => $composableBuilder(
    column: $table.maxDiscount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get appliesToAllOutlets => $composableBuilder(
    column: $table.appliesToAllOutlets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionPromosRefs(
    Expression<bool> Function($$TransactionPromosTableFilterComposer f) f,
  ) {
    final $$TransactionPromosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionPromos,
      getReferencedColumn: (t) => t.promoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionPromosTableFilterComposer(
            $db: $db,
            $table: $db.transactionPromos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PromosTableOrderingComposer
    extends Composer<_$AppDatabase, $PromosTable> {
  $$PromosTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promoType => $composableBuilder(
    column: $table.promoType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxDiscount => $composableBuilder(
    column: $table.maxDiscount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appliesToAllOutlets => $composableBuilder(
    column: $table.appliesToAllOutlets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PromosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromosTable> {
  $$PromosTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get promoType =>
      $composableBuilder(column: $table.promoType, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxDiscount => $composableBuilder(
    column: $table.maxDiscount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get appliesToAllOutlets => $composableBuilder(
    column: $table.appliesToAllOutlets,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  Expression<T> transactionPromosRefs<T extends Object>(
    Expression<T> Function($$TransactionPromosTableAnnotationComposer a) f,
  ) {
    final $$TransactionPromosTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionPromos,
          getReferencedColumn: (t) => t.promoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionPromosTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionPromos,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PromosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PromosTable,
          Promo,
          $$PromosTableFilterComposer,
          $$PromosTableOrderingComposer,
          $$PromosTableAnnotationComposer,
          $$PromosTableCreateCompanionBuilder,
          $$PromosTableUpdateCompanionBuilder,
          (Promo, $$PromosTableReferences),
          Promo,
          PrefetchHooks Function({bool transactionPromosRefs})
        > {
  $$PromosTableTableManager(_$AppDatabase db, $PromosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> promoType = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<double> discountValue = const Value.absent(),
                Value<double?> maxDiscount = const Value.absent(),
                Value<bool> appliesToAllOutlets = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromosCompanion(
                id: id,
                name: name,
                description: description,
                promoType: promoType,
                targetType: targetType,
                discountValue: discountValue,
                maxDiscount: maxDiscount,
                appliesToAllOutlets: appliesToAllOutlets,
                status: status,
                startDate: startDate,
                endDate: endDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required String promoType,
                required String targetType,
                required double discountValue,
                Value<double?> maxDiscount = const Value.absent(),
                Value<bool> appliesToAllOutlets = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromosCompanion.insert(
                id: id,
                name: name,
                description: description,
                promoType: promoType,
                targetType: targetType,
                discountValue: discountValue,
                maxDiscount: maxDiscount,
                appliesToAllOutlets: appliesToAllOutlets,
                status: status,
                startDate: startDate,
                endDate: endDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PromosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({transactionPromosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionPromosRefs) db.transactionPromos,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionPromosRefs)
                    await $_getPrefetchedData<
                      Promo,
                      $PromosTable,
                      TransactionPromo
                    >(
                      currentTable: table,
                      referencedTable: $$PromosTableReferences
                          ._transactionPromosRefsTable(db),
                      managerFromTypedResult: (p0) => $$PromosTableReferences(
                        db,
                        table,
                        p0,
                      ).transactionPromosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.promoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PromosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PromosTable,
      Promo,
      $$PromosTableFilterComposer,
      $$PromosTableOrderingComposer,
      $$PromosTableAnnotationComposer,
      $$PromosTableCreateCompanionBuilder,
      $$PromosTableUpdateCompanionBuilder,
      (Promo, $$PromosTableReferences),
      Promo,
      PrefetchHooks Function({bool transactionPromosRefs})
    >;
typedef $$TransactionPromosTableCreateCompanionBuilder =
    TransactionPromosCompanion Function({
      required String id,
      required String transactionId,
      Value<String?> promoId,
      required String promoName,
      Value<String?> promoCode,
      required String discountType,
      Value<double> discountValue,
      Value<double> discountAmount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TransactionPromosTableUpdateCompanionBuilder =
    TransactionPromosCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String?> promoId,
      Value<String> promoName,
      Value<String?> promoCode,
      Value<String> discountType,
      Value<double> discountValue,
      Value<double> discountAmount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TransactionPromosTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionPromosTable,
          TransactionPromo
        > {
  $$TransactionPromosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) => db
      .transactions
      .createAlias('transaction_promos__transaction_id__transactions__id');

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

  static $PromosTable _promoIdTable(_$AppDatabase db) =>
      db.promos.createAlias('transaction_promos__promo_id__promos__id');

  $$PromosTableProcessedTableManager? get promoId {
    final $_column = $_itemColumn<String>('promo_id');
    if ($_column == null) return null;
    final manager = $$PromosTableTableManager(
      $_db,
      $_db.promos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_promoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionPromosTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionPromosTable> {
  $$TransactionPromosTableFilterComposer({
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

  ColumnFilters<String> get promoName => $composableBuilder(
    column: $table.promoName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promoCode => $composableBuilder(
    column: $table.promoCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$PromosTableFilterComposer get promoId {
    final $$PromosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.promoId,
      referencedTable: $db.promos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PromosTableFilterComposer(
            $db: $db,
            $table: $db.promos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionPromosTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionPromosTable> {
  $$TransactionPromosTableOrderingComposer({
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

  ColumnOrderings<String> get promoName => $composableBuilder(
    column: $table.promoName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promoCode => $composableBuilder(
    column: $table.promoCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$PromosTableOrderingComposer get promoId {
    final $$PromosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.promoId,
      referencedTable: $db.promos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PromosTableOrderingComposer(
            $db: $db,
            $table: $db.promos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionPromosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionPromosTable> {
  $$TransactionPromosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get promoName =>
      $composableBuilder(column: $table.promoName, builder: (column) => column);

  GeneratedColumn<String> get promoCode =>
      $composableBuilder(column: $table.promoCode, builder: (column) => column);

  GeneratedColumn<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

  $$PromosTableAnnotationComposer get promoId {
    final $$PromosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.promoId,
      referencedTable: $db.promos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PromosTableAnnotationComposer(
            $db: $db,
            $table: $db.promos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionPromosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionPromosTable,
          TransactionPromo,
          $$TransactionPromosTableFilterComposer,
          $$TransactionPromosTableOrderingComposer,
          $$TransactionPromosTableAnnotationComposer,
          $$TransactionPromosTableCreateCompanionBuilder,
          $$TransactionPromosTableUpdateCompanionBuilder,
          (TransactionPromo, $$TransactionPromosTableReferences),
          TransactionPromo,
          PrefetchHooks Function({bool transactionId, bool promoId})
        > {
  $$TransactionPromosTableTableManager(
    _$AppDatabase db,
    $TransactionPromosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionPromosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionPromosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionPromosTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String?> promoId = const Value.absent(),
                Value<String> promoName = const Value.absent(),
                Value<String?> promoCode = const Value.absent(),
                Value<String> discountType = const Value.absent(),
                Value<double> discountValue = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionPromosCompanion(
                id: id,
                transactionId: transactionId,
                promoId: promoId,
                promoName: promoName,
                promoCode: promoCode,
                discountType: discountType,
                discountValue: discountValue,
                discountAmount: discountAmount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                Value<String?> promoId = const Value.absent(),
                required String promoName,
                Value<String?> promoCode = const Value.absent(),
                required String discountType,
                Value<double> discountValue = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionPromosCompanion.insert(
                id: id,
                transactionId: transactionId,
                promoId: promoId,
                promoName: promoName,
                promoCode: promoCode,
                discountType: discountType,
                discountValue: discountValue,
                discountAmount: discountAmount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionPromosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false, promoId = false}) {
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
                                    $$TransactionPromosTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$TransactionPromosTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (promoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.promoId,
                                referencedTable:
                                    $$TransactionPromosTableReferences
                                        ._promoIdTable(db),
                                referencedColumn:
                                    $$TransactionPromosTableReferences
                                        ._promoIdTable(db)
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

typedef $$TransactionPromosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionPromosTable,
      TransactionPromo,
      $$TransactionPromosTableFilterComposer,
      $$TransactionPromosTableOrderingComposer,
      $$TransactionPromosTableAnnotationComposer,
      $$TransactionPromosTableCreateCompanionBuilder,
      $$TransactionPromosTableUpdateCompanionBuilder,
      (TransactionPromo, $$TransactionPromosTableReferences),
      TransactionPromo,
      PrefetchHooks Function({bool transactionId, bool promoId})
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
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String id,
      required String name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> code,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> code,
      Value<int> rowid,
    });

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
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

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
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

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
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

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                phone: phone,
                email: email,
                code: code,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                email: email,
                code: code,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$ProductCategoriesTableTableManager get productCategories =>
      $$ProductCategoriesTableTableManager(_db, _db.productCategories);
  $$VariantGroupsTableTableManager get variantGroups =>
      $$VariantGroupsTableTableManager(_db, _db.variantGroups);
  $$VariantGroupOptionsTableTableManager get variantGroupOptions =>
      $$VariantGroupOptionsTableTableManager(_db, _db.variantGroupOptions);
  $$InventoriesTableTableManager get inventories =>
      $$InventoriesTableTableManager(_db, _db.inventories);
  $$InventoryItemVariantGroupOptionsTableTableManager
  get inventoryItemVariantGroupOptions =>
      $$InventoryItemVariantGroupOptionsTableTableManager(
        _db,
        _db.inventoryItemVariantGroupOptions,
      );
  $$ModifierGroupsTableTableManager get modifierGroups =>
      $$ModifierGroupsTableTableManager(_db, _db.modifierGroups);
  $$ProductModifierGroupsTableTableManager get productModifierGroups =>
      $$ProductModifierGroupsTableTableManager(_db, _db.productModifierGroups);
  $$ModifierOptionsTableTableManager get modifierOptions =>
      $$ModifierOptionsTableTableManager(_db, _db.modifierOptions);
  $$ProductPricesTableTableManager get productPrices =>
      $$ProductPricesTableTableManager(_db, _db.productPrices);
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
  $$PromosTableTableManager get promos =>
      $$PromosTableTableManager(_db, _db.promos);
  $$TransactionPromosTableTableManager get transactionPromos =>
      $$TransactionPromosTableTableManager(_db, _db.transactionPromos);
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db, _db.employees);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
}
