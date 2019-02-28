-- Up

create table Contents(
  id    integer primary key,
  title text  not null
);

create table Versions(
  id        integer  primary key,
  date      datetime not null,
  body      text     not null,
  contentId integer  not null,

  foreign key(contentId) references Contents(id)
);

create table Tags(
  id   integer primary key,
  name text    unique
);

create table VersionsTags(
  id        integer primary key,
  versionId integer not null,
  tagId     integer not null,

  foreign key(versionId) references Versions(id)
  foreign key(tagId)     references Tags(id)
);

-- Down

drop table Contents;
drop table Versions;
drop table Tags;
drop table VersionsTags;
