const String readRepositories = r'''
  query ReadRepositories($nRepositories: Int!, $after: String) {
    viewer {
      repositories(first: $nRepositories, after: $after) {
        pageInfo {
          endCursor
          hasNextPage
        }
        nodes {
          id
          name
          isPrivate
          createdAt
        }
      }
    }
  }
''';
