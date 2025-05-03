# Developer's Note on the `num2text` Package

Hello!

Thank you for exploring the `num2text` package. This note is intended to provide important context regarding its development journey, current state, and how the community can help improve it.

**1. Development Context: Background & AI Assistance**

As the primary developer, I want to be upfront that I am relatively new to Dart and Flutter development (early-intermediate level). To tackle the ambitious scope of supporting **69 languages**, I leaned heavily on AI language models like Gemini throughout the development process. These AI tools were invaluable for:

- Generating foundational code structures for language implementations and configuration options.
- Providing initial drafts of number word translations and currency information across diverse languages.
- Assisting with documentation and generating initial test case ideas.

While I have reviewed and implemented tests based on this generated code, the sheer volume and linguistic complexity mean that my personal expertise does not cover all 69 languages included in the package.

**2. Current State (Version 0.0.3) & Known Limitations**

This package is currently in an **early release phase (version 0.0.3)**. Significant effort has gone into implementing the core logic and a comprehensive set of tests (compared to 0.0.1), leading to improved accuracy for many basic conversions. However, despite these advancements:

- The library has **not yet undergone rigorous linguistic review or extensive real-world validation** across _all_ 69 languages by native speakers or language experts.
- The implementations heavily rely on the AI's initial linguistic models, which may not capture all nuances.

Therefore, it is highly probable that the library contains **inaccuracies**, particularly in the following areas:

- **Linguistic Nuances:** Subtle differences in phrasing or number word usage in specific contexts.
- **Complex Grammatical Rules:** Handling of gender agreement, case declension, complex plural forms (especially in languages like Slavic or Baltic), irregular forms, or unique numbering systems (like vigesimal systems).
- **Edge Cases:** Handling of extremely large numbers, numbers close to limits, or specific cultural number usages might be incorrect.

🚨 **Important Warning to Users:** 🚨
Given the breadth of language support and the early stage of development, users are **strongly urged** to carefully verify the output of this library, especially for critical applications (e.g., financial) or for languages where high accuracy is non-negotiable. Relying solely on the package's output without independent verification is not recommended at this stage.

**3. Contributing & Helping Improve `num2text`**

This project is released under the permissive MIT license with the explicit goal of being a **community-driven starting point**. Your contributions are incredibly valuable in making this library more robust and accurate.

- **Clone & Fork:** Feel free to clone the repository, fork it, and experiment or build upon it.
- **Contribute via GitHub:** Issues and Pull Requests are warmly welcomed on the [GitHub repository](https://github.com/vemines/num2text). Whether it's reporting a bug, suggesting an enhancement, or submitting a code fix, your input is needed.

**How You Can Help Most Effectively (Especially with Linguistic Fixes): Provide Test Cases!**

Correcting language-specific output errors is challenging for a developer who doesn't have native or expert proficiency in every language. The **most impactful way** you can contribute, report an issue, or propose a fix for incorrect linguistic output is by **providing concrete examples with the correct expected result**.

Please include:

- The specific number(s) that produce incorrect output.
- The language code and any options used.
- The _actual_ output you are getting (if possible).
- The **correct expected output** for that number in that language/context.

Including code examples demonstrating the incorrect input and the expected correct output is ideal, for instance:

```dart
// In your Issue description or PR test file:
final converter = Num2Text(initialLang: Lang.XX);
expect(converter.convert(123), equals("correct expected output in language XX"));
expect(converter.convert(specific_edge_case_number, options: SomeOptions(...)), equals("correct edge case output for language XX"));
```
