// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jiruhub_detail.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetJiruHubDetailCollection on Isar {
  IsarCollection<JiruHubDetail> get jiruHubDetails => this.collection();
}

const JiruHubDetailSchema = CollectionSchema(
  name: r'JiruHubDetail',
  id: 1216732533843362544,
  properties: {
    r'aniListID': PropertySchema(
      id: 0,
      name: r'aniListID',
      type: IsarType.string,
    ),
    r'data': PropertySchema(
      id: 1,
      name: r'data',
      type: IsarType.string,
    ),
    r'package': PropertySchema(
      id: 2,
      name: r'package',
      type: IsarType.string,
    ),
    r'tmdbID': PropertySchema(
      id: 3,
      name: r'tmdbID',
      type: IsarType.long,
    ),
    r'updateTime': PropertySchema(
      id: 4,
      name: r'updateTime',
      type: IsarType.dateTime,
    ),
    r'url': PropertySchema(
      id: 5,
      name: r'url',
      type: IsarType.string,
    )
  },
  estimateSize: _jiruHubDetailEstimateSize,
  serialize: _jiruHubDetailSerialize,
  deserialize: _jiruHubDetailDeserialize,
  deserializeProp: _jiruHubDetailDeserializeProp,
  idName: r'id',
  indexes: {
    r'package&url': IndexSchema(
      id: 1543775085104464922,
      name: r'package&url',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'package',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'url',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _jiruHubDetailGetId,
  getLinks: _jiruHubDetailGetLinks,
  attach: _jiruHubDetailAttach,
  version: '3.1.0+1',
);

int _jiruHubDetailEstimateSize(
  JiruHubDetail object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aniListID;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.data.length * 3;
  bytesCount += 3 + object.package.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _jiruHubDetailSerialize(
  JiruHubDetail object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aniListID);
  writer.writeString(offsets[1], object.data);
  writer.writeString(offsets[2], object.package);
  writer.writeLong(offsets[3], object.tmdbID);
  writer.writeDateTime(offsets[4], object.updateTime);
  writer.writeString(offsets[5], object.url);
}

JiruHubDetail _jiruHubDetailDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = JiruHubDetail();
  object.aniListID = reader.readStringOrNull(offsets[0]);
  object.data = reader.readString(offsets[1]);
  object.id = id;
  object.package = reader.readString(offsets[2]);
  object.tmdbID = reader.readLongOrNull(offsets[3]);
  object.updateTime = reader.readDateTime(offsets[4]);
  object.url = reader.readString(offsets[5]);
  return object;
}

P _jiruHubDetailDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _jiruHubDetailGetId(JiruHubDetail object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _jiruHubDetailGetLinks(JiruHubDetail object) {
  return [];
}

void _jiruHubDetailAttach(
    IsarCollection<dynamic> col, Id id, JiruHubDetail object) {
  object.id = id;
}

extension JiruHubDetailQueryWhereSort
    on QueryBuilder<JiruHubDetail, JiruHubDetail, QWhere> {
  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension JiruHubDetailQueryWhere
    on QueryBuilder<JiruHubDetail, JiruHubDetail, QWhereClause> {
  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterWhereClause>
      packageEqualToAnyUrl(String package) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'package&url',
        value: [package],
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterWhereClause>
      packageNotEqualToAnyUrl(String package) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'package&url',
              lower: [],
              upper: [package],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'package&url',
              lower: [package],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'package&url',
              lower: [package],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'package&url',
              lower: [],
              upper: [package],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterWhereClause>
      packageUrlEqualTo(String package, String url) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'package&url',
        value: [package, url],
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterWhereClause>
      packageEqualToUrlNotEqualTo(String package, String url) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'package&url',
              lower: [package],
              upper: [package, url],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'package&url',
              lower: [package, url],
              includeLower: false,
              upper: [package],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'package&url',
              lower: [package, url],
              includeLower: false,
              upper: [package],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'package&url',
              lower: [package],
              upper: [package, url],
              includeUpper: false,
            ));
      }
    });
  }
}

extension JiruHubDetailQueryFilter
    on QueryBuilder<JiruHubDetail, JiruHubDetail, QFilterCondition> {
  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aniListID',
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aniListID',
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aniListID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aniListID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aniListID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aniListID',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aniListID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aniListID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aniListID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aniListID',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aniListID',
        value: '',
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      aniListIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aniListID',
        value: '',
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> dataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      dataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      dataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> dataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      dataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      dataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      dataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> dataMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      dataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: '',
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      dataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data',
        value: '',
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      packageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'package',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      packageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'package',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      packageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'package',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      packageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'package',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      packageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'package',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      packageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'package',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      packageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'package',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      packageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'package',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      packageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'package',
        value: '',
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      packageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'package',
        value: '',
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      tmdbIDIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tmdbID',
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      tmdbIDIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tmdbID',
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      tmdbIDEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbID',
        value: value,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      tmdbIDGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tmdbID',
        value: value,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      tmdbIDLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tmdbID',
        value: value,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      tmdbIDBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tmdbID',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      updateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      updateTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      updateTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      updateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> urlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition> urlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterFilterCondition>
      urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }
}

extension JiruHubDetailQueryObject
    on QueryBuilder<JiruHubDetail, JiruHubDetail, QFilterCondition> {}

extension JiruHubDetailQueryLinks
    on QueryBuilder<JiruHubDetail, JiruHubDetail, QFilterCondition> {}

extension JiruHubDetailQuerySortBy
    on QueryBuilder<JiruHubDetail, JiruHubDetail, QSortBy> {
  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> sortByAniListID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aniListID', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy>
      sortByAniListIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aniListID', Sort.desc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> sortByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> sortByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> sortByPackage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'package', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> sortByPackageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'package', Sort.desc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> sortByTmdbID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbID', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> sortByTmdbIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbID', Sort.desc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> sortByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy>
      sortByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension JiruHubDetailQuerySortThenBy
    on QueryBuilder<JiruHubDetail, JiruHubDetail, QSortThenBy> {
  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenByAniListID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aniListID', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy>
      thenByAniListIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aniListID', Sort.desc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenByPackage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'package', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenByPackageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'package', Sort.desc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenByTmdbID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbID', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenByTmdbIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbID', Sort.desc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy>
      thenByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension JiruHubDetailQueryWhereDistinct
    on QueryBuilder<JiruHubDetail, JiruHubDetail, QDistinct> {
  QueryBuilder<JiruHubDetail, JiruHubDetail, QDistinct> distinctByAniListID(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aniListID', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QDistinct> distinctByData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QDistinct> distinctByPackage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'package', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QDistinct> distinctByTmdbID() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tmdbID');
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QDistinct> distinctByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateTime');
    });
  }

  QueryBuilder<JiruHubDetail, JiruHubDetail, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension JiruHubDetailQueryProperty
    on QueryBuilder<JiruHubDetail, JiruHubDetail, QQueryProperty> {
  QueryBuilder<JiruHubDetail, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<JiruHubDetail, String?, QQueryOperations> aniListIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aniListID');
    });
  }

  QueryBuilder<JiruHubDetail, String, QQueryOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data');
    });
  }

  QueryBuilder<JiruHubDetail, String, QQueryOperations> packageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'package');
    });
  }

  QueryBuilder<JiruHubDetail, int?, QQueryOperations> tmdbIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tmdbID');
    });
  }

  QueryBuilder<JiruHubDetail, DateTime, QQueryOperations> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateTime');
    });
  }

  QueryBuilder<JiruHubDetail, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
