---
layout: page
title: Quiz Demo
within: programming
---

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas nec neque
vitae nisl gravida finibus. In ipsum quam, varius eget felis quis, pharetra
viverra dolor. Aliquam feugiat eros nisl, vitae placerat tellus pellentesque
sed. Suspendisse potenti. Cras congue elit eget arcu ornare varius. Aliquam erat
volutpat. Duis tempus viverra turpis in sodales.

Donec imperdiet condimentum felis, et convallis orci lobortis a. Interdum et
malesuada fames ac ante ipsum primis in faucibus. Mauris sed vestibulum diam.
Sed at pharetra odio. Cras vehicula sapien et vehicula feugiat. Pellentesque
faucibus, mauris sit amet pretium ornare, lacus lorem ullamcorper nisi, nec
aliquam nisl elit sit amet est. In accumsan odio sed vehicula venenatis. Donec
maximus non turpis eget bibendum. Fusce eget dictum libero, ut elementum metus.
Morbi at metus sapien. Sed et sapien in libero aliquam efficitur. Quisque tellus
magna, fermentum eu mauris sit amet, aliquam pharetra erat. Suspendisse cursus
mauris at ipsum faucibus luctus. Vestibulum eget metus ipsum. Suspendisse et
dolor commodo, sagittis sem at, elementum velit.

```quiz
topic = "Syntax"

[[questions]]
type = "short answer" # or "sa"
# Parsed as block.
question = "What keyword is used to define a function in Python?"
answer = "def"

[[questions]]
type = "multiple choice" # or "mc"
question = "Which of the following is a valid variable name in Python?"
# Each choice is parsed as inline.
choices = [
  "`1_variable`",
  "`variable-name`",
  "`variable_name`",
  "`class`"
]
answer = 3
context = "`class` is a keyword in Python."
```

<button type="button" class="quiz-clear-button">
Clear all answers (for demo/testing)
</button>

Suspendisse tellus ante, lobortis vel dui at, rutrum sagittis justo. Integer
elementum urna ut lectus viverra, posuere condimentum metus pulvinar. Etiam
lorem lorem, ultrices nec pellentesque pellentesque, eleifend quis lacus.
Quisque tortor erat, ultricies a sagittis at, ultricies vitae leo. Donec
faucibus tincidunt rhoncus. Suspendisse potenti. Pellentesque efficitur tortor
et commodo pretium. Nunc imperdiet fringilla leo ut consectetur. Suspendisse
pretium congue ligula scelerisque cursus. Morbi lorem quam, imperdiet eget
vestibulum a, tincidunt sit amet magna. Nunc lobortis risus dui, in ullamcorper
massa sodales sed.

Curabitur et nibh mollis, sollicitudin dui varius, suscipit elit. Etiam
porttitor ornare nulla, vitae molestie risus congue in. Nam pellentesque sed ex
eget iaculis. Vivamus volutpat et libero et pharetra. Sed ac ultrices magna.
Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac
turpis egestas. Morbi consectetur lorem sit amet tortor fermentum, eu volutpat
tellus tempor. Nunc enim mi, tempor id rhoncus id, dapibus at lorem. Fusce
semper orci felis, a elementum magna hendrerit et. Sed hendrerit semper lacus
sit amet mattis. Sed sollicitudin consequat turpis quis facilisis. Pellentesque
ornare tortor tortor, a sodales quam vestibulum a. Mauris vel eleifend nisi.
Nunc at viverra est.

```quiz
topic = "Control Flow"

[[questions]]
type = "multiple answer" # or "ma"
question = """Which of the following looping constructs are available in \
Python?"""
choices = [
  "for",
  "do while",
  "loop",
  "while"
]
answer = [1, 4]

[[questions]]
type = "mc"

# Fenced code blocks for a question have to use opposite delimiter (backtick vs
# tilde) than that used for the quiz itself:
question = """Do the following two code blocks have the same behaviour?
~~~python
if a:
    f()
elif b:
    g()
~~~
~~~python
if a:
    f()
else:
    if b:
        g()
~~~
"""
choices = [
  "Yes",
  "No"
]
answer = 1
```

<button type="button" class="quiz-clear-button">
Clear all answers (for demo/testing)
</button>

Vivamus erat neque, luctus quis mauris laoreet, efficitur rhoncus felis. Lorem
ipsum dolor sit amet, consectetur adipiscing elit. Etiam nec sodales velit.
Suspendisse vel mi porta, vestibulum turpis eu, aliquam erat. Phasellus tempus
nisi in tellus venenatis, eget accumsan nisl vehicula. Class aptent taciti
sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Duis
sagittis tellus velit, id convallis ex suscipit quis. Praesent sodales urna non
sapien hendrerit scelerisque.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vitae ultrices
tortor, vitae volutpat ex. Cras a nibh convallis, cursus sem sed, aliquam est.
Etiam et enim ex. Sed porta enim vitae nunc gravida placerat. Suspendisse
lobortis neque quis bibendum dapibus. Fusce arcu dolor, tincidunt a metus
hendrerit, ullamcorper auctor velit. Proin vestibulum euismod mattis. Morbi
venenatis lectus aliquam feugiat pulvinar. Phasellus fringilla sapien eu
molestie vestibulum.
