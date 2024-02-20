let mainContainer = undefined;
let chars = undefined;
let limit = undefined;
const mainCreate = () => {

    const template = `
        <main id="main-container">
            <header id="main-header">
                <p id="icon"><i class="fa-solid fa-users"></i></p>
                <h1>Selecionar Personagens</h1>
                <p id="numberofchars">4/5 personagens</p>
            </header>
            <section id="characters-section">
                <ul id="characters"></ul>
            </section>
        </main>`
    
    const htmlTemplate = new DOMParser().parseFromString(template, "text/html")

    document.querySelector("body").appendChild(htmlTemplate.querySelector("#main-container"));

    mainContainer = document.querySelector("#main-container");
}

const charCreationCreate = () => {
    const template = `
        <main id="charCreate-container">
            <header id="charCreate-header">
                <p id="icon"><i class="fa-solid fa-users"></i></p>
                <div id="title">
                    <h1>Criação Personagem</h1>
                    <p id="chardetails">Insere os detalhes do personagem</p>
                </div>
            </header>

            <div id="form-container">
                <div id="gender-container">
                    <div id="gender-title">Escolher Género</div>
                    <div id="gender-selector">
                        <div id="male" class="btn selected">Masculino</div>
                        <div id="female" class="btn">Feminino</div>
                    </div>
                </div>

                <div id="name-container">
                    <div id="firstname">
                        <i class="fa-solid fa-id-card"></i>
                        <input type="text" id="firstname-input" name="firstname">
                    </div>

                    <div id="lastname">
                        <i class="fa-solid fa-id-card"></i>
                        <input type="text" id="lastname-input" name="lastname">
                    </div>
                </div>

                <div id="bdate">
                    <i class="fa-solid fa-id-card"></i>
                    <input id="date" type="date" name="date">
                </div>

                <div id="buttons">
                    <div id="select" class="btn">Selecionar</div>
                    <div id="cancel" class="btn">Cancelar</div>
                </div>
            </div>
        </main>`

    const htmlTemplate = new DOMParser().parseFromString(template, "text/html")

    document.querySelector("body").appendChild(htmlTemplate.querySelector("#charCreate-container"));

    mainContainer = document.querySelector("#charCreate-container");
}

const clearBody = () => {
    document.querySelector("body").innerHTML = ``;
    mainContainer = undefined;
}

window.addEventListener("message", function(event) {
    let data = event.data;
    let procedure = data.procedure;

    if (procedure === 'init') {
        
        clearBody();
        mainCreate();

        if (data.chars !== undefined) {
            chars = data.chars;
            limit = data.limit;
        }

        let numberchars = chars.length;
        
        document.querySelector("#numberofchars").innerText =  `${numberchars}/${limit} personagens`

        const charObj = document.querySelector("#characters");
        for (let i = 0; i < numberchars; i++) {
            
            let char = chars[i];

            if(!char.cid) new Error("CID não informado!")

            const template = `
                <li class="character">
                    <div class="char-info">
                    <div class="mugshot"></div>
                        <p class="name"> ${char.firstname} ${char.lastname}</p>
                        <img src="img/pixolo.png">
                    </div>
                    <div class="select" data-cid=${char.cid} data-skin=${char.skin} data-model=${char.model}>Selecionar</div>
                </li>`
                
            const htmlTemplate = new DOMParser().parseFromString(template, "text/html")

            const character = htmlTemplate.querySelector(".character")

            character.querySelector(".mugshot").style.backgroundImage = `url(${char.mug})`
    
            charObj.appendChild(character);

            const sel = character.querySelector(".select")

            sel.addEventListener("click", (e) => {
                $.post('https://pb-charselector/selectchar', JSON.stringify({
                    cid: sel.dataset.cid,
                    skin: sel.dataset.skin,
                    model: sel.dataset.model
                }));
            })
        }
        if (numberchars < limit) {
            const template = `
                <li class="character">
                    <div class="create-container">
                        <p><i class="fa-solid fa-plus"></i> Criar um novo personagem</p>
                    </div>
                    <div class="select">Selecionar</div>
                </li>
            `
            const htmlTemplate = new DOMParser().parseFromString(template, "text/html")

            const character = htmlTemplate.querySelector(".character")
    
            charObj.appendChild(character);

            const sel = character.querySelector(".select")
                
            sel.addEventListener("click", (e) => {
                mainContainer.classList.toggle('showing')
                clearBody();
                $.post('https://pb-charselector/createNewChar', JSON.stringify({}));
            })
        }
        mainContainer.classList.toggle('showing')
    } else if (procedure === 'createChar') {
        charCreationCreate();

        let gender = "male"
        const btns = mainContainer.querySelector("#gender-selector").querySelectorAll(".btn")
        
        btns.forEach((btn) => {
            btn.addEventListener("click", () => {
                
                btns.forEach((btn) => {
                    btn.classList.remove('selected')
                })

               gender = btn.getAttribute('id')

                btn.classList.add('selected')
            })
        });

        mainContainer.querySelector("#select").addEventListener("click", () => {
            const firstname = mainContainer.querySelector("#firstname-input").value
            const lastname = mainContainer.querySelector("#lastname-input").value
            const bdate = mainContainer.querySelector("#date").value
            $.post('https://pb-charselector/CreateChar', JSON.stringify({
                firstname: firstname,
                lastname: lastname,
                gender: gender,
                bdate: bdate
            }));
        })

        mainContainer.querySelector("#cancel").addEventListener("click", () => {
            mainContainer.classList.toggle('showing')
            clearBody();
            $.post('https://pb-charselector/cancelCreateChar', JSON.stringify({}));
        })

        mainContainer.classList.toggle('showing')
    } else {
        mainContainer.classList.toggle('showing');
        clearBody();
        chars = undefined;
        limit = undefined;
    }
})