alias Bookclub.Accounts.User
alias Bookclub.Clubs.{
  Book,
  Club,
  ClubMembers
}
alias Bookclub.Repo

users = [
  # Password: foxbox!!
  %User{
    first_name: "Team",
    last_name: "Foxbox",
    email: "team@foxbox.co",
    type: 2,
    phone_number: "123",
    password_hash: "$2b$12$IXUy7.mUK2iUYTNEXnvFJO5qNu0Q1kmSMFooWwwoTYtj8Zitme3By"
  },
  %User{
    first_name: "Fernando",
    last_name: "Schuindt",
    email: "fernando@foxbox.co",
    type: 2,
    phone_number: "1234",
    password_hash: "$2b$12$7de.lrkurTf.UBGHyyIrCe3fD2.FFheGtZmKsaSGZQQY3HzTtiS9."
  },
  # Password: foxbox!!
  %User{
    first_name: "Tiago",
    last_name: "Davi",
    email: "tiago@foxbox.co",
    type: 2,
    phone_number: "1235",
    password_hash: "$2b$12$IXUy7.mUK2iUYTNEXnvFJO5qNu0Q1kmSMFooWwwoTYtj8Zitme3By"
  },
  # Password: foxbox!!
  %User{
    first_name: "Carlos",
    last_name: "Ubri",
    email: "carlos@foxbox.co",
    type: 2,
    phone_number: "1236",
    password_hash: "$2b$12$IXUy7.mUK2iUYTNEXnvFJO5qNu0Q1kmSMFooWwwoTYtj8Zitme3By"
  }
]

create_book = fn ->
  Repo.insert!(%Book{
    name: "Structure and Interpretation of Computer Programs",
    author: "Harold Abelson, Gerald Jay Sussman, Julie Sussman",
    photo_url: "https://i.postimg.cc/WNk5dCMH/sicp.jpg",
    google_book_id: "6QOXQgAACAAJ",
    chapters: 5
  })
end

create_club = fn user, book ->
  Repo.insert!(%Club{user_id: user.id, book_id: book.id, join_code: "foxbox"})
end

join_club = fn club, users ->
  Enum.each(users, fn user -> ClubMembers.join_club!(user, club) end)
end

created_users = Enum.map(users, fn user -> Repo.insert!(user) end)

user = hd(created_users)
book = create_book.()
club = create_club.(user, book)
join_club.(club, created_users)
