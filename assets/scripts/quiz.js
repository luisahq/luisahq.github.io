'use strict'

function parentUntil (el, query) {
    if (el.tagName === 'HTML') return el
    if (el.matches(query)) return el
    return parentUntil(el.parentElement, query)
}

function compareAnswers (type, submitted, correct) {
    if (submitted === correct) return 'correct'

    if (type === 'multiplechoice' && correct.indexOf(',') !== -1) {
        const correctAnswers = correct.split(',')
        const submittedAnswers = submitted.split(',')
        let n = 0

        submittedAnswers
            .forEach(a => n += correctAnswers.indexOf(a) === -1 ? 0 : 1)

        return n === correctAnswers.length ? 'correct' : 'partial'
    }

    return 'incorrect'
}

function view () {
    document.querySelectorAll('div.quiz').forEach(el => {
        const state = localStorage.getItem(el.id)
        if (state === null) return
        el.classList.add(state)

        el.querySelectorAll('fieldset').forEach(f => {
            const inputs = f.querySelectorAll('input')
            inputs.forEach(input => input.setAttribute('disabled', ''))
            const submittedAnswer = localStorage.getItem(f.id)
            if (submittedAnswer === null) return
            const correctAnswer = f.dataset.answer

            const result = compareAnswers(
                f.dataset.questionType,
                submittedAnswer,
                correctAnswer
            )

            f.dataset.correct = result
        })
    })
}

function save () {
    const quiz = document.querySelector('div.quiz.active')

    quiz
        .querySelectorAll('fieldset')
        .forEach(f => {
            if (f.dataset.questionType === 'shortanswer')
                localStorage.setItem(f.id, f.querySelector('input').value)

            const answers = []

            f
                .querySelectorAll('input')
                .forEach((el, i) => { if (el.checked) answers.push(i + 1) })

            localStorage.setItem(f.id, answers.map(n => n.toString()).join(','))
        })

    let notCorrect = 0

    quiz
        .querySelectorAll('fieldset')
        .forEach(f => { if (f.dataset.correct !== 'correct') ++notCorrect })

    localStorage.setItem(quiz.id, notCorrect > 0 ? 'attempted' : 'complete')
}

function activateQuiz (el) {
    el.classList.add('active')
    document
        .querySelectorAll('.post-content > :not(#' + el.id + ')')
        .forEach(el => { el.classList.add('invisible') })
}

function deactivateQuiz (el) {
    el.classList.remove('active')
    document
        .querySelectorAll('.post-content > :not(#' + el.id + ')')
        .forEach(el => { el.classList.remove('invisible') })
}

document.querySelectorAll('.quiz-start-button').forEach(el => {
    el.removeAttribute('disabled')
    el.textContent = 'Start Quiz'
    el.addEventListener('click', e => activateQuiz(parentUntil(el, 'div.quiz')))
})

document.querySelectorAll('.quiz-cancel-button').forEach(el => {
    el.addEventListener(
        'click',
        e => deactivateQuiz(parentUntil(el, 'div.quiz'))
    )
})
