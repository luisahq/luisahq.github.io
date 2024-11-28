const startButtons = document.querySelectorAll('.quiz-start-button')
const cancelButtons = document.querySelectorAll('.quiz-cancel-button')

function parentUntil (el, query) {
    if (el.tagName === 'HTML') return el
    if (el.matches(query)) return el
    return parentUntil(el.parentElement, query)
}

startButtons.forEach(el => {
    el.removeAttribute('disabled')
    el.textContent = 'Start Quiz'
    const quiz = parentUntil(el, 'div.quiz')

    el.addEventListener('click', e => {
        quiz.classList.add('active')

        document
            .querySelectorAll('.post-content > :not(#' + quiz.id + ')')
            .forEach(el => { el.classList.add('invisible') })
    })
})

cancelButtons.forEach(el => {
    const quiz = parentUntil(el, 'div.quiz')

    el.addEventListener('click', e => {
        quiz.classList.remove('active')

        document
            .querySelectorAll('.post-content > :not(#' + quiz.id + ')')
            .forEach(el => { el.classList.remove('invisible') })
    })
})
