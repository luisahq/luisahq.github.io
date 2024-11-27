const startButtons = document.querySelectorAll('.quiz-start-button')

startButtons.forEach((startButton, i) => {
    startButton.removeAttribute('disabled')
    startButton.textContent = 'Start Quiz'

    startButton.addEventListener('click', (e) => {
        if (startButton.hasAttribute('disabled'))
            startButton.removeAttribute('disabled')
        else startButton.setAttribute('disabled', '')

        startButton.classList.add('hidden')
        startButton.nextElementSibling.classList.remove('hidden')
    })
})
