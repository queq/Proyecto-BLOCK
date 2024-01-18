// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/Urna.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite is Urna(TestsAccounts.getAccount(0)) {
    // Remix IDE no permite poner tildes ni siquiera en los comentarios :(
    address cuentaOwner = TestsAccounts.getAccount(0);
    address cuentaVotante1 = TestsAccounts.getAccount(1);
    address cuentaVotante2 = TestsAccounts.getAccount(2);
    address cuentaVotante3 = TestsAccounts.getAccount(3);
    address cuentaVotante4 = TestsAccounts.getAccount(4);
    address cuentaVotante5 = TestsAccounts.getAccount(5);
    address cuentaVotante6 = TestsAccounts.getAccount(6);

    uint conteoVotos;

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Creacion de jornada

    /// #sender: account-0
    function probarCreacionJornada() public {
        Assert.ok(msg.sender == cuentaOwner, "Cuenta no tiene permiso 'owner'.");
        crearJornada("Jornada de prueba 1", block.timestamp + 48 hours);
        // Assert.equal(urnaPrueba.jornadaVotacion.nombre, "Jornada de prueba 1", "Jornada no tiene el nombre esperado.");
    }

    // Creacióo de candidatos
    /// #sender: account-0
    function probarCreacionCandidatos() public {
        Assert.ok(msg.sender == cuentaOwner, "Cuenta no tiene permiso 'owner'.");
        inscribirCandidato("Partido A", "Candidato 1");
        inscribirCandidato("Partido B", "Candidato 2");
        inscribirCandidato("Partido C", "Candidato 3");
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Creacion de participantes
    /// #sender: account-1
    function probarCreacionParticipante1() public {
        Assert.ok(msg.sender == cuentaVotante1, "Cuenta no corresponde al votante deseado.");
        inscribirParticipante("Votante 1", 19);
    }

    /// #sender: account-2
    function probarCreacionParticipante2() public {
        Assert.ok(msg.sender == cuentaVotante2, "Cuenta no corresponde al votante deseado.");
        inscribirParticipante("Votante 2", 30);
    }

    /// #sender: account-3
    function probarCreacionParticipante3() public {
        Assert.ok(msg.sender == cuentaVotante3, "Cuenta no corresponde al votante deseado.");
        inscribirParticipante("Votante 3", 55);
    }

    /// #sender: account-4
    function probarCreacionParticipante4() public {
        Assert.ok(msg.sender == cuentaVotante4, "Cuenta no corresponde al votante deseado.");
        inscribirParticipante("Votante 4", 70);
    }

    /// #sender: account-5
    function probarCreacionParticipante5() public {
        Assert.ok(msg.sender == cuentaVotante5, "Cuenta no corresponde al votante deseado.");
        inscribirParticipante("Votante 5", 27);
    }

    /// #sender: account-6
    function probarCreacionParticipante6() public {
        Assert.ok(msg.sender == cuentaVotante6, "Cuenta no corresponde al votante deseado.");
        inscribirParticipante("Votante 6", 25);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Prueba consulta candidatos
    /// #sender: account-1
    function probarConsultaCandidatos() public {
        Assert.ok(msg.sender == cuentaVotante1, "Cuenta no corresponde al votante deseado.");
        try (this).verNumeroCandidatos() returns (uint r) {
            Assert.equal(r, 3, "Numero de candidatos no corresponde a los 3 registrados.");
        } catch Error(string memory reason) { 
            Assert.equal(reason, "Error", "Error no fue el identificado");
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Proceso de votacion
    /// #sender: account-1
    function probarVotoParticipante1() public {
        Assert.ok(msg.sender == cuentaVotante1, "Cuenta no corresponde al votante deseado.");
        enviarVoto(0);
    }

    /// #sender: account-2
    function probarVotoParticipante2() public {
        Assert.ok(msg.sender == cuentaVotante2, "Cuenta no corresponde al votante deseado.");
        enviarVoto(2);
    }

    /// #sender: account-3
    function probarVotoParticipante3() public {
        Assert.ok(msg.sender == cuentaVotante3, "Cuenta no corresponde al votante deseado.");
        enviarVoto(2);
    }

    /// #sender: account-4
    function probarVotoParticipante4() public {
        Assert.ok(msg.sender == cuentaVotante4, "Cuenta no corresponde al votante deseado.");
        enviarVoto(1);
    }

    /// #sender: account-5
    function probarVotoParticipante5() public {
        Assert.ok(msg.sender == cuentaVotante5, "Cuenta no corresponde al votante deseado.");
        enviarVoto(1);
    }

    /// #sender: account-6
    function probarVotoParticipante6() public {
        Assert.ok(msg.sender == cuentaVotante6, "Cuenta no corresponde al votante deseado.");
        enviarVoto(2);
    }

    /// #sender: account-1
    function probarVerVotoParticipante1() public {
        Assert.ok(msg.sender == cuentaVotante1, "Cuenta no corresponde al votante deseado.");
        try (this).verVoto() returns (uint r) {
            Assert.equal(r, 0, "Voto del participante 1 no corresponde al registrado");
        } catch Error(string memory reason) { 
            Assert.equal(reason, "Error", "Error no fue el identificado");
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Resultados de votacion
    /// #sender: account-6
    function probarConteoVotos() public {
        Assert.ok(msg.sender == cuentaVotante6, "Cuenta no corresponde al votante deseado.");
        try (this).verTotalVotos() returns (uint r) {
            conteoVotos = r;
            Assert.equal(r, 6, "Numero de votos no corresponde a los 6 registrados.");
        } catch Error(string memory reason) { 
            Assert.equal(reason, "Error", "Error no fue el identificado");
        }
    }

    /// #sender: account-0
    function finPruebas() public {
        Assert.ok(true, "Error.");
    }
}
    