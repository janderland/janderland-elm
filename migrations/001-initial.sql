-- Up

create table Contents(
  id    integer primary key,
  title text  not null
);

create unique index Contents_title_index on Contents(title);



create table Versions(
  id        integer  primary key,
  date      datetime not null,
  body      text     not null,
  contentId integer  not null,

  foreign key(contentId) references Contents(id)
);

create index Versions_contentId_index on Versions(contentId);



create table Tags(
  id   integer primary key,
  name text    unique
);

create unique index Tags_name_index on Tags(name);



create table VersionsTags(
  id        integer primary key,
  versionId integer not null,
  tagId     integer not null,

  foreign key(versionId) references Versions(id),
  foreign key(tagId)     references Tags(id)
);

create index VersionsTags_versionId_index on VersionsTags(versionId);
create index VersionsTags_tagId_index     on VersionsTags(tagId);



-- Down

drop index Contents_title_index;
drop table Contents;

drop index Versions_contentId_index;
drop table Versions;

drop index Tags_name_index;
drop table Tags;

drop index VersionsTags_versionId_index;
drop index VersionsTags_tagId_index;
drop table VersionsTags;
