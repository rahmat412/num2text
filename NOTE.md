# Developer's Note (Regarding `num2text` Package)

Hello!

Thank you for checking out the `num2text` package. This note is intended to provide some important context about its development process and current state.

**1. Developer Background & AI Assistance:**

As the primary developer, I want to be transparent that I am relatively new to Dart and Flutter development (junior level). To tackle the complexity of supporting 69 languages, I utilized AI language models Gemini extensively during the development process. These tools were instrumental in:

- Generating boilerplate code for language implementations and options classes.
- Providing initial translations and grammatical structures for number words and currency info across various languages.
- Assisting with documentation and test case generation.

While I reviewed and tested the generated code, the sheer volume and linguistic diversity mean that my personal expertise doesn't cover all languages included.

**2. Package Status & Potential Inaccuracies:**

This is an **early release (version 0.0.1)**. Although a significant number of tests have been implemented and pass for basic conversions, the library has **not undergone rigorous linguistic review or real-world validation** across all 69 languages.

Therefore, it's highly possible that:

- **Linguistic nuances** might be incorrect.
- **Complex grammatical rules** (like gender agreement, case declension, specific plural forms in Slavic languages, vigesimal systems, etc.) may have errors or simplifications.
- **Currency formatting conventions** might not perfectly match all regional standards.
- **Edge cases** might not be handled correctly.

**Users are strongly advised to carefully verify the output of this library, especially for critical applications or for languages they have proficiency in, before relying on it.**

**3. Open Invitation for Improvement & Contributions:**

This project is released under the MIT license with the explicit intention of being a **starting point**. I wholeheartedly encourage the community to build upon this foundation.

- **Clone & Fork:** Please feel free to clone the repository, fork it, and create your own enhanced versions.
- **Contribute:** If you have expertise in a particular language and notice errors or areas for improvement, your contributions (Issues, Pull Requests) would be invaluable and are warmly welcomed on the [GitHub repository](https://github.com/vemines/num2text).
- **Feedback:** Any feedback regarding inaccuracies or suggestions for improvement is appreciated.

**Important Note on Issues & Pull Requests:**

- **Language Expertise:** Please understand that even with explanations, I may not fully grasp the intricate grammatical logic of every language.
- **Require Test Cases:** To effectively verify fixes and prevent regressions, **please include concrete test cases with expected results** when submitting Issues or Pull Requests related to incorrect language output. This means providing code examples like:
  ```dart
  // In your Issue description or PR test file:
  expect(converter.convert(123, options: SomeOptions(...)), equals("correct expected output in the language"));
  expect(converter.convert(specific_edge_case_number), equals("correct edge case output"));
  ```
  Seeing the expected output helps me visually confirm the correction, even if the underlying linguistic rules are complex for me to fully internalize. Contributions with clear test cases are much easier to review and merge confidently.

My hope is that this library, even in its current state, can serve as a useful foundation for developers needing number-to-text conversion, and that collaboration can make it more robust and accurate over time.

Thank you for your understanding and potential contributions!
