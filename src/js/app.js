App = {
    web3Provider: null,
    contracts: {},

    init: function () {
        // Load records to hold slots for Haiku bounties (was pets).
        $.getJSON('../pets.json', function (data) {
            var petsRow = $('#petsRow');
            var petTemplate = $('#petTemplate');

            for (i = 0; i < data.length; i++) {
                petTemplate.find('.panel-title').text(data[i].name);
                //petTemplate.find('img').attr('src', data[i].picture);
                petTemplate.find('.pet-breed').text(data[i].breed);
                petTemplate.find('.pet-age').text(data[i].age);
                petTemplate.find('.pet-location').text(data[i].location);
                petTemplate.find('.btn-adopt').attr('data-id', data[i].id);

                petsRow.append(petTemplate.html());
            }
        });

        return App.initWeb3();
    },

    initWeb3: function () {
        // KMS I added this
        // Is there an injected web3 instance?
        if (typeof web3 !== 'undefined') {
            App.web3Provider = web3.currentProvider;
        } else {
            // If no injected web3 instance is detected, fall back to Ganache-cli
            // this is insecure and not suitable for production
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
        }

        web3 = new Web3(App.web3Provider);

        return App.initContract();
    },

    initContract: function () {
        // KMS I added this
        $.getJSON('BountyMarketHaiku.json', function (data) {
            // Get the necessary contract artifact file and instantiate it with truffle-contract
            var BountyArtifact = data;
            App.contracts.BountyMarketHaiku = TruffleContract(BountyArtifact);

            // Set the provider for our contract
            App.contracts.BountyMarketHaiku.setProvider(App.web3Provider);

            // Use our contract to update the UI
            return App.refreshUI();
        });

        return App.bindEvents();
    },

    bindEvents: function () {

        // Create Bounty
        $(document).on('click', '.btn-bcreate', App.handleCreateBounty);

        // Create Proposal
        $(document).on('click', '.btn-pcreate', App.handleCreateProposal);

        // Approve Proposal
        $(document).on('click', '.btn-papprove', App.handleApprove);

        // Reject Proposal
        $(document).on('click', '.btn-preject', App.handleReject);
        
        // Withdraw Ether
        $(document).on('click', '.btn-withdraw', App.handleWithdraw);
    },

    handleCreateBounty: function (event) {
        event.preventDefault();

        var bountyInstance;

        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            var account = accounts[0];

            App.contracts.BountyMarketHaiku.deployed().then(function (instance) {
                bountyInstance = instance;
                // https://truffleframework.com/docs/truffle/getting-started/interacting-with-your-contracts            
                return bountyInstance.createBounty($("#btnCreateBountyDesc").val(), {
                    from: account,
                    value: web3.toWei($("#btnCreateBountyEther").val(), "ether")
                });
            }).then(function (result) {
                return App.refreshUI();
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    handleCreateProposal: function (event) {
        event.preventDefault();

        var bountyInstance;

        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            var account = accounts[0];

            App.contracts.BountyMarketHaiku.deployed().then(function (instance) {
                bountyInstance = instance;
                // https://truffleframework.com/docs/truffle/getting-started/interacting-with-your-contracts            
                //var bId = $("#btnCreateProposalBountyId").val();
                //var pDesc = $("#btnCreateProposalDesc").val();                
                //return bountyInstance.createProposal(bId, pDesc, { from: account });
                return bountyInstance.createProposal($("#btnCreateProposalBountyId").val(), $("#btnCreateProposalDesc").val(), { from: account });
            }).then(function (result) {
                return App.refreshUI();
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    refreshUI: function (adopters, account) {

        // KMS more experimental
        var myaccount = web3.eth.accounts[0];

        // KMS I added this
        var bountyInstance;
        var marketBal;

        App.contracts.BountyMarketHaiku.deployed().then(function (instance) {

            // promise.then( doneCallback, failCallback )
            // When you return something from a then() callback, it's a bit magic. 
            //If you return a value, the next then() is called with that value. 
            // However, if you return something promise-like, the next then() waits on it,
            // and is only called when that promise settles (succeeds/fails).
            bountyInstance = instance;

            //return bountyInstance.getCountOpenBounties.call();
            return bountyInstance.getMarketBalance.call();

        }).then(function (mktBalance) {

            // KMS more experimental stuff
            $("#ethAddress").text("My Current Address: " + myaccount);

            // TODO fix all buttons

            //$("#btnCreateBountyDesc").val("Wandered lonely / as a / cloud ");
            //$("#btnCreateBountyId").val("4");

            // Whole market balance in ether     
            var ethBalance = mktBalance / 1000000000000000000;
            $("#uiMarketBalance").val(ethBalance);

            return bountyInstance.getBountyDetailAll.call();

            //for (i = 0; i < adopters.length; i++) {
            //    if (adopters[i] !== '0x0000000000000000000000000000000000000000') {
            //        $('.panel-pet').eq(i).find('button').text('success').attr('disabled', true);
            //    }
            //}
        }).then(function (btyDetailAll) {

            // uint Index
            var arrayIndexes = btyDetailAll[0];
            var arrayIsOpen = btyDetailAll[1];
            var arrayOwner = btyDetailAll[2];
            var arrayValue = btyDetailAll[3];

            for (i = 0; i < arrayValue.length; i++) {
                $('.panel-title').eq(i).text('Bounty ID: ' + i);
                $('.pet-age').eq(i).text(arrayValue[i] / 1000000000000000000);
                $('.pet-location').eq(i).text(arrayOwner[i]);
                //$('.panel-pet').eq(i).find('#btnApprove').text(arrayValue[i]).attr('disabled', true);
            }

            return bountyInstance.getBountyDesc.call(0);

        }).then(function (bDesc0) {
            $('.pet-breed').eq(0).text(bDesc0);
            return bountyInstance.getBountyDesc.call(1);

        }).then(function (bDesc1) {
            $('.pet-breed').eq(1).text(bDesc1);
            return bountyInstance.getBountyDesc.call(2);

        }).then(function (bDesc2) {
            $('.pet-breed').eq(2).text(bDesc2);
            return bountyInstance.getBountyDesc.call(3);

        }).then(function (bDesc3) {
            $('.pet-breed').eq(3).text(bDesc3);
            return bountyInstance.getBountyDesc.call(4);

        }).then(function (bDesc4) {
            $('.pet-breed').eq(4).text(bDesc4);
            return bountyInstance.getBountyDesc.call(5);

        }).then(function (bDesc5) {
            $('.pet-breed').eq(5).text(bDesc5);
            return bountyInstance.getBountyDesc.call(6);

        }).then(function (bDesc6) {
            $('.pet-breed').eq(6).text(bDesc6);
            return bountyInstance.getBountyDesc.call(7);

        }).then(function (bDesc7) {
            $('.pet-breed').eq(7).text(bDesc7);
            return bountyInstance.getBountyDesc.call(8);

        }).then(function (bDesc8) {
            $('.pet-breed').eq(8).text(bDesc8);
            return bountyInstance.getBountyDesc.call(9);

        }).then(function (bDesc9) {
            $('.pet-breed').eq(9).text(bDesc9);
            return bountyInstance.getBountyDesc.call(10);

        }).then(function (bDesc10) {
            $('.pet-breed').eq(10).text(bDesc10);
            return bountyInstance.getBountyDesc.call(11);

        }).then(function (bDesc11) {
            $('.pet-breed').eq(11).text(bDesc11);
            return bountyInstance.getBountyDesc.call(12);

        }).then(function (bDesc12) {
            $('.pet-breed').eq(12).text(bDesc12);
            return bountyInstance.getBountyDesc.call(13);

        }).then(function (bDesc13) {
            $('.pet-breed').eq(13).text(bDesc13);
            return bountyInstance.getBountyDesc.call(14);

        }).then(function (bDesc14) {
            $('.pet-breed').eq(14).text(bDesc14);
            return bountyInstance.getBountyDesc.call(15);

        }).then(function (bDesc15) {
            $('.pet-breed').eq(15).text(bDesc15);
            // end

        }).catch(function (err) {
            console.log(err.message);
        });
    },

    handleApprove: function (event) {
        event.preventDefault();       
        var bountyInstance;
        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }
            var account = accounts[0];
            App.contracts.BountyMarketHaiku.deployed().then(function (instance) {
                bountyInstance = instance;                
                return bountyInstance.approveProposal($("#btnApproveBountyId").val(), $("#btnApproveProposalId").val(), { from: account });
            }).then(function (result) {
                return App.refreshUI();
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    handleWithdraw: function (event) {
        event.preventDefault();       
        var bountyInstance;
        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }
            var account = accounts[0];
            App.contracts.BountyMarketHaiku.deployed().then(function (instance) {
                bountyInstance = instance;                
                return bountyInstance.makeWithdrawal({ from: account });
            }).then(function (result) {
                return App.refreshUI();
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    handleReject: function (event) {
        event.preventDefault();       
        var bountyInstance;
        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }
            var account = accounts[0];
            App.contracts.BountyMarketHaiku.deployed().then(function (instance) {
                bountyInstance = instance;                
                return bountyInstance.rejectProposal($("#btnRejectBountyId").val(), $("#btnRejectProposalId").val(), { from: account });
            }).then(function (result) {
                return App.refreshUI();
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    }

};

$(function () {
    $(window).load(function () {
        App.init();
    });
});