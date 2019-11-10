import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:invoiceninja_flutter/data/models/company_model.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';

part 'user_model.g.dart';

abstract class UserListResponse
    implements Built<UserListResponse, UserListResponseBuilder> {
  factory UserListResponse([void updates(UserListResponseBuilder b)]) =
      _$UserListResponse;

  UserListResponse._();

  BuiltList<UserEntity> get data;

  static Serializer<UserListResponse> get serializer =>
      _$userListResponseSerializer;
}

abstract class UserItemResponse
    implements Built<UserItemResponse, UserItemResponseBuilder> {
  factory UserItemResponse([void updates(UserItemResponseBuilder b)]) =
      _$UserItemResponse;

  UserItemResponse._();

  UserEntity get data;

  static Serializer<UserItemResponse> get serializer =>
      _$userItemResponseSerializer;
}

class UserFields {
  static const String firstName = 'first_name';
  static const String lastName = 'last_name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String updatedAt = 'updated_at';
}

abstract class UserEntity extends Object
    with BaseEntity, SelectableEntity
    implements Built<UserEntity, UserEntityBuilder> {
  factory UserEntity({String id}) {
    return _$UserEntity._(
      id: id ?? BaseEntity.nextId,
      isChanged: false,
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      updatedAt: 0,
      archivedAt: 0,
      isDeleted: false,
      isAdmin: false,
    );
  }

  UserEntity._();

  @override
  EntityType get entityType {
    return EntityType.user;
  }

  @BuiltValueField(wireName: 'first_name')
  String get firstName;

  @BuiltValueField(wireName: 'last_name')
  String get lastName;

  String get email;

  String get phone;

  @nullable
  @BuiltValueField(wireName: 'is_admin')
  bool get isAdmin;

  String get fullName => (firstName + ' ' + lastName).trim();

  bool canEdit(BaseEntity entity) =>
      entity.createdUserId == id || entity.assignedUserId == id;

  @override
  String get listDisplayName {
    return fullName;
  }

  int compareTo(UserEntity user, String sortField, bool sortAscending) {
    int response = 0;
    final UserEntity userA = sortAscending ? this : user;
    final UserEntity userB = sortAscending ? user : this;

    switch (sortField) {
      case UserFields.firstName:
        response = userA.firstName.compareTo(userB.firstName);
        break;
      case UserFields.email:
        response = userA.email.compareTo(userB.email);
        break;
    }

    if (response == 0) {
      return userA.lastName
          .toLowerCase()
          .compareTo(userB.lastName.toLowerCase());
    } else {
      return response;
    }
  }

  @override
  bool matchesFilter(String filter) {
    if (filter == null || filter.isEmpty) {
      return true;
    }
    filter = filter.toLowerCase();

    if (firstName.toLowerCase().contains(filter)) {
      return true;
    } else if (lastName.toLowerCase().contains(filter)) {
      return true;
    } else if (phone.toLowerCase().contains(filter)) {
      return true;
    } else if (email.toLowerCase().contains(filter)) {
      return true;
    }

    return false;
  }

  @override
  String matchesFilterValue(String filter) {
    if (filter == null || filter.isEmpty) {
      return null;
    }

    filter = filter.toLowerCase();

    if (email.toLowerCase().contains(filter)) {
      return email;
    } else if (phone.toLowerCase().contains(filter)) {
      return phone;
    }

    return null;
  }

  @override
  List<EntityAction> getActions(
      {UserCompanyEntity userCompany,
      ClientEntity client,
      bool includeEdit = false,
      bool multiselect = false}) {
    final actions = <EntityAction>[];

    // TODO remove ??
    if (!(isDeleted ?? false)) {
      if (includeEdit && userCompany.canEditEntity(this)) {
        actions.add(EntityAction.edit);
      }
    }

    if (actions.isNotEmpty) {
      actions.add(null);
    }

    return actions..addAll(super.getActions(userCompany: userCompany));
  }

  @override
  double get listDisplayAmount => null;

  @override
  FormatNumberType get listDisplayAmountType => null;

  static Serializer<UserEntity> get serializer => _$userEntitySerializer;
}