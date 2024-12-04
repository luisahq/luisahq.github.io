'use strict'

function parentUntil (el, query) {
    if (el.tagName === 'HTML') return el
    if (el.matches(query)) return el
    return parentUntil(el.parentElement, query)
}

function calcScore (type, submitted, correct) {
    if (submitted === correct) return 100

    if (type === 'ma') {
        const corrects = correct.split(',')
        const submitteds = submitted.split(',')
        let n = 0

        for (const a of submitteds) {
            if (corrects.indexOf(a) === -1) return 0
            n += 1
        }

        return n === corrects.length
            ? 100
            : n === 0 ? 0 : Math.round(100 * n / corrects.length)
    }

    return 0
}

function save () {
    const quiz = document.querySelector('div.quiz.active')
    if (quiz === null) return;
    let not100 = 0

    for (const f of quiz.querySelectorAll('fieldset')) {
        // Save student answers for each question in active quiz.
        if (f.dataset.questionType === 'sa')
            localStorage.setItem(f.id, f.querySelector('input').value)

        else if (f.dataset.questionType === 'mc') {
            const inputs = f.querySelectorAll('input')
            let i = 0
            for (; i < inputs.length; ++i)
                if (inputs[i].checked) {
                    localStorage.setItem(f.id, (i + 1).toString())
                    break
                }

            if (i === inputs.length) localStorage.setItem(f.id, '')
        }

        else {
            const checked = []
            f
                .querySelectorAll('input')
                .forEach((el, i) => {
                    if (el.checked) checked.push((i + 1).toString())
                })

            localStorage.setItem(f.id, checked.join(','))
        }

        // Calculate score (percentage mark) for each question, save it, and use
        // these to determine if quiz should be marked as only attempted, or as
        // complete if every answer is correct.
        const score = calcScore(
            f.dataset.questionType,
            localStorage.getItem(f.id),
            f.dataset.answer
        )

        if (score !== 100) ++not100;
        localStorage.setItem(f.id + 'Score', score.toString())
    }

    localStorage.setItem(quiz.id, not100 > 0 ? 'attempted' : 'complete')
}

function render () {
    document.querySelectorAll('div.quiz').forEach(el => {
        const state = localStorage.getItem(el.id)
        if (state === null) return
        if (state === 'complete') el.classList.remove('attempted')
        el.classList.add(state)

        for (const f of el.querySelectorAll('fieldset')) {
            const inputs = f.querySelectorAll('input')
            const submitted = localStorage.getItem(f.id)

            if (f.dataset.questionType === 'sa') inputs[0].value = submitted
            else if (f.dataset.questionType === 'mc') {
                if (submitted !== '')
                    inputs[parseInt(submitted, 10) - 1].checked = true
            }

            else {
                if (submitted !== '')
                    submitted
                        .split(',')
                        .map(x => parseInt(x, 10))
                        .forEach(n => { inputs[n - 1].checked = true })
            }

            const _score = localStorage.getItem(f.id + 'Score')
            f.dataset.score = _score
            if (!el.classList.contains('active'))
                inputs.forEach(input => input.setAttribute('disabled', ''))

            else {
                if (_score === null || _score !== '100')
                    inputs.forEach(input => input.removeAttribute('disabled'))

                else inputs.forEach(input => input.setAttribute('disabled', ''))
            }
        }
    })
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
