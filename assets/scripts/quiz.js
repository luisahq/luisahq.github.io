const startButtons = document.querySelectorAll('.quiz-start-button')

startButtons.forEach(el => {
    el.removeAttribute('disabled')
    el.textContent = 'Start Quiz'

    el.addEventListener('click', e => {
        if (el.hasAttribute('disabled')) el.removeAttribute('disabled')
        else el.setAttribute('disabled', '')
        el.classList.add('hidden')
        el.nextElementSibling.classList.remove('hidden')
        const id = el.parentElement.id

        document
            .querySelectorAll('.post-content > :not(#' + id + ')')
            .forEach(el => { el.classList.add('hidden') })
    })
})
