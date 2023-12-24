import { complement, isEmpty, remove } from "./helpers.js";

type Token = [string, number];
type Tokens = Token[];

// Add to stop TS from complaining.
const T = (...args: any) => true;
const isOrToken = (token: Token): boolean =>
  Boolean(token && token[0] === "or");
const isWhitespaceToken = ([token]: Token): boolean => /^\s/.test(token);
const isTextToken = complement(isWhitespaceToken);
const isLeftOfOr = ([, index]: Token, tokens: Tokens): boolean =>
  isOrToken(tokens[index + 2]);
const isRightOfOr = ([, index]: Token, tokens: Tokens): boolean =>
  isOrToken(tokens[index - 2]);
const isPartOfOrToken = (token: Token, tokens: Tokens): boolean =>
  isLeftOfOr(token, tokens) || isRightOfOr(token, tokens);
const tokenIndex = ([, index]: Token) => index;
const tokenValue = ([value]: Token) => value;

function parse(input: string): Tokens {
  // Regular expression to match:
  // 1. Quoted strings (either double or single quotes): "..." or '...'
  // 2. Series of non-whitespace characters (\S+)
  // 3. Series of whitespace characters (\s+)
  const regex = /(['"][\s\S]*?['"]|\S+|\s+)/g;

  // Array to store tokens
  const tokens: Tokens = [];

  // Loop through the matches in the input string and push them to the tokens array
  let match: RegExpExecArray | null;
  while ((match = regex.exec(input)) != null) {
    tokens.push([match[0], tokens.length]);
  }

  return tokens;
}

function tokenFromStringIndex(
  tokens: Tokens,
  stringIndex: number,
): Token | undefined {
  let currentIndex = 0;

  return tokens.find(([token]) => {
    currentIndex += token.length;

    return currentIndex >= stringIndex;
  });
}

const replaceTokenValue = (
  tokens: Tokens,
  token: Token,
  value: string,
): Tokens => {
  tokens = [...tokens];

  const index = findTokenIndex(token, tokens);

  tokens[index] = [value, token[1]];
  return tokens;
};

const findTokenIndex = (token: Token, tokens: Tokens) => {
  const index = tokens.findIndex(([, index]) => index === token[1]);

  if (index === -1)
    throw new Error(
      `Not able to find token ${token[0]} with index ${token[1]}`,
    );

  return index;
};

function removeToken(tokens: Tokens, token: Token): Tokens {
  const index = findTokenIndex(token, tokens);

  if (index === -1)
    throw new Error(
      `Not able to find token ${token[0]} with index ${token[1]}`,
    );

  if (isWhitespaceToken(token))
    throw new Error("Removing whitespace tokens is nonsensical.");

  // Remove the or when removing a token with or
  if (isRightOfOr(token, tokens)) {
    // Remove everything from index till index - 3
    return remove(index, -3, tokens);
  }

  if (isLeftOfOr(token, tokens)) {
    // Remove everything from index till index + 3
    return remove(index, 3, tokens);
  }

  // Is not part of an or so remove index - 1 or index + 1. Don't go out of bounds.
  if (index > 0) return remove(index, -1, tokens);

  return remove(index, 1, tokens);
}

function stringify(tokens: Tokens): string {
  return tokens.map(tokenValue).join("");
}

type Predicate = (_: any) => boolean;

const or = (before: Predicate, token: Predicate) => (issue: string) =>
  before(issue) || token(issue);
const and = (before: Predicate, token: Predicate) => (issue: string) =>
  before(issue) && token(issue);

const predicate =
  <T>(matcher: (token: Token, value: T) => boolean) =>
  (queryTokens: Tokens) => {
    // Would be nice to use a curry helper
    const matches =
      (a: Token) =>
      (b: T): boolean =>
        matcher(a, b);

    const passes = (tokens: Tokens, predicate = T): Predicate => {
      if (isEmpty(tokens)) return predicate;

      const [token, ...rest] = tokens;

      // Don't change the predicate
      if (isOrToken(token) || isWhitespaceToken(token))
        return passes(rest, predicate);

      if (isRightOfOr(token, queryTokens)) {
        return passes(rest, or(predicate, matches(token)));
      }

      if (isLeftOfOr(token, queryTokens)) {
        return and(predicate, passes(rest, matches(token)));
      }

      return passes(rest, and(predicate, matches(token)));
    };

    const pred = passes(queryTokens);

    return (item: T): boolean => pred(item);
  };

const map = <T>(
  fn: (token: Token, index: number, tokens: Tokens) => T,
  tokens: Tokens,
): T[] =>
  tokens.reduce((acc: T[], token, index) => {
    if (isWhitespaceToken(token)) return acc;

    acc.push(fn(token, index, tokens));

    return acc;
  }, []);

// TODO: Cleanup unused function
export {
  parse,
  predicate,
  stringify,
  isWhitespaceToken,
  isOrToken,
  replaceTokenValue,
  isRightOfOr,
  removeToken,
  tokenFromStringIndex,
  map,
  isTextToken,
};
